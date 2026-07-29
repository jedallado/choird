<?php

namespace App\Services\Set;

use App\Models\Set;

class DeleteSet
{
    public function handle(Set $set): void
    {
        $set->delete();
    }
}
