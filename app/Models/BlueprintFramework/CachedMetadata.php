<?php

namespace Pterodactyl\Models\BlueprintFramework;

class ExtensionRemoteMetadata extends Model
{
    protected $table = 'extension_remote_metadata';
    protected $casts = [
        'metadata' => 'array',
        'fetched_at' => 'datetime',
    ];
    protected $fillable = ['identifier', 'metadata', 'fetched_at'];

    /**
     * Return the latest_version string for a given extension identifier, or null if not found.
     */
    public static function latestVersionFor(string $identifier): ?string
    {
        $row = static::where('identifier', $identifier)->first(['metadata']);

        if (! $row) {
            return null;
        }

        return $row->metadata['latest_version'] ?? null;
    }
}
