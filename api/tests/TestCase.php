<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /**
     * Sanctum remembers the user on the guard for the life of this process.
     * Drop that cache so the next request is authenticated only by its token.
     */
    protected function withBearer(string $token): static
    {
        $this->app['auth']->forgetGuards();

        return $this->withToken($token);
    }
}
