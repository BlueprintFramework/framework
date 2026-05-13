<?php

namespace Pterodactyl\Models;

class ExtensionCachedMetadata extends Model
{
  protected $table = 'extension_cached_metadata';
  protected $casts = [
    'metadata' => 'array',
    'fetched_at' => 'datetime',
  ];
  protected $fillable = ['identifier', 'metadata', 'fetched_at'];
  public $timestamps = true;

  // return the latest_version for a given extension identifier, or null if not found
  public static function latestVersionFor(string $identifier): ?string
  {
    $row = static::where('identifier', $identifier)->first(['metadata']);

    if (! $row) {
      return null;
    }

    return $row->metadata['latest_version'] ?? null;
  }
}
