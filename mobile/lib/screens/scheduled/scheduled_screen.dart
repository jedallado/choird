import 'package:flutter/material.dart';

import '../../models/set_list.dart';
import '../../services/set_api.dart';
import 'set_detail_screen.dart';

class ScheduledScreen extends StatefulWidget {
  const ScheduledScreen({super.key});

  @override
  State<ScheduledScreen> createState() => _ScheduledScreenState();
}

class _ScheduledScreenState extends State<ScheduledScreen> {
  final SetApi _setApi = SetApi();
  late Future<List<SetList>> _setsFuture;

  @override
  void initState() {
    super.initState();
    _setsFuture = _setApi.fetchSets();
  }

  Future<void> _refreshSets() async {
    setState(() {
      _setsFuture = _setApi.fetchSets();
    });

    await _setsFuture;
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

  void _openSetDetail(SetList setList) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SetDetailScreen(setList: setList),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Lists'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSets,
        child: FutureBuilder<List<SetList>>(
          future: _setsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
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
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _refreshSets,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final sets = snapshot.data ?? [];

            if (sets.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: const Center(
                      child: Text('No set lists yet.'),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sets.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final set = sets[index];
                final songCount = set.setSongs.length;
                final songLabel =
                    songCount == 1 ? '1 song' : '$songCount songs';

                return ListTile(
                  title: Text(set.displayName),
                  subtitle: Text(
                    '${_formatScheduledFor(context, set.scheduledFor)} · $songLabel',
                  ),
                  onTap: () => _openSetDetail(set),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
