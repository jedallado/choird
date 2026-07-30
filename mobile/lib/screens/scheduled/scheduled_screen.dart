import 'package:flutter/material.dart';

import '../../models/set_list.dart';
import '../../services/set_repository.dart';
import 'set_detail_screen.dart';

class ScheduledScreen extends StatefulWidget {
  const ScheduledScreen({super.key, SetRepository? repository})
    : _repository = repository;

  final SetRepository? _repository;

  @override
  State<ScheduledScreen> createState() => _ScheduledScreenState();
}

class _ScheduledScreenState extends State<ScheduledScreen> {
  late final SetRepository _repository = widget._repository ?? SetRepository();

  List<SetList> _sets = [];
  DateTime? _lastSyncedAt;
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadLocalSets();
  }

  Future<void> _loadLocalSets() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final sets = await _repository.getLocalSets();
      final lastSyncedAt = await _repository.getLastSyncedAt();
      if (!mounted) {
        return;
      }

      setState(() {
        _sets = sets;
        _lastSyncedAt = lastSyncedAt;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _syncSets() async {
    if (_isSyncing) {
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final sets = await _repository.syncSets();
      final lastSyncedAt = await _repository.getLastSyncedAt();
      if (!mounted) {
        return;
      }

      setState(() {
        _sets = sets;
        _lastSyncedAt = lastSyncedAt;
        _loadError = null;
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set lists synced.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSyncing = false;
      });

      final message = error.toString();
      if (_sets.isEmpty) {
        setState(() {
          _loadError = message;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not sync set lists. $message')),
        );
      }
    }
  }

  String _formatScheduledFor(BuildContext context, DateTime scheduledFor) {
    final localizations = MaterialLocalizations.of(context);
    final local = scheduledFor.toLocal();
    final date = localizations.formatMediumDate(local);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
    );

    return '$date · $time';
  }

  String _formatLastSyncedAt(DateTime syncedAt) {
    final local = syncedAt.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  void _openSetDetail(SetList setList) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SetDetailScreen(setList: setList),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null && _sets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSyncing ? null : _syncSets,
                      child: Text(_isSyncing ? 'Syncing…' : 'Sync set lists'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_sets.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_download_outlined, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Connect once to download set lists for offline use.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isSyncing ? null : _syncSets,
                      child: Text(_isSyncing ? 'Syncing…' : 'Sync set lists'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _sets.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final set = _sets[index];
        final songCount = set.setSongs.length;
        final songLabel = songCount == 1 ? '1 song' : '$songCount songs';

        return ListTile(
          title: Text(set.displayName),
          subtitle: Text(
            '${_formatScheduledFor(context, set.scheduledFor)} · $songLabel',
          ),
          onTap: () => _openSetDetail(set),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Lists'),
        actions: [
          if (_isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Sync set lists',
              onPressed: _syncSets,
              icon: const Icon(Icons.sync),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_lastSyncedAt != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Last synced: ${_formatLastSyncedAt(_lastSyncedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _syncSets,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }
}
