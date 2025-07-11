<?php

namespace Database\Seeders;

use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Console\BlueprintConsoleLibrary as BlueprintExtensionLibrary;
use Illuminate\Database\Seeder;

class BlueprintSeeder extends Seeder
{
  /**
   * The schema configuration array.
   *
   * @var array
   */
  private array $schema = [
    'internal' => [
      'seed' => [
        'default' => true,
        'type' => 'boolean',
      ],
      'uuid' => [
        'default' => null,
        'type' => 'string',
      ],
      'version' => [
        'latest' => [
          'default' => null,
          'type' => 'string',
        ],
      ],
    ],
    'flags' => [
      'disable_attribution' => [
        'default' => false,
        'type' => 'boolean',
        'hidden' => false,
      ],
      'is_developer' => [
        'default' => false,
        'type' => 'boolean',
        'hidden' => false,
      ],
      'show_in_sidebar' => [
        'default' => false,
        'type' => 'boolean',
        'hidden' => false,
      ],
      'telemetry_enabled' => [
        'default' => true,
        'type' => 'boolean',
        'hidden' => false,
      ],
    ],
  ];

  public function getSchema(): array
  {
    return $this->schema;
  }

  public function getDefaultsForFlag(string $flag): mixed
  {
    $parts = explode(':', $flag);
    $current = $this->schema;

    foreach ($parts as $part) {
      if (!isset($current[$part])) {
        return null;
      }
      $current = $current[$part];
    }

    return $current['default'] ?? null;
  }

  /**
   * @var BlueprintExtensionLibrary
   */
  private BlueprintExtensionLibrary $blueprint;

  /**
   * BlueprintSeeder constructor.
   */
  public function __construct(BlueprintExtensionLibrary $blueprint)
  {
    $this->blueprint = $blueprint;
  }

  /**
   * Run the database seeds.
   */
  public function run(): void
  {
    $isSeeded = $this->blueprint->dbGet('blueprint', 'internal:seed', false);

    if ($isSeeded) {
      $this->updateRecords();
    } else {
      $this->createRecords();
    }
  }

  /**
   * Create initial records in the database.
   */
  private function createRecords(): void
  {
    $records = [];

    foreach ($this->schema as $category => $values) {
      $categoryRecords = $this->buildCategoryRecords($category, $values);
      $records = array_merge($records, $categoryRecords);
    }

    if (!empty($records)) {
      $this->blueprint->dbSetMany('blueprint', $records);
    }

    // Mark as seeded after successful creation
    $this->blueprint->dbSet('blueprint', 'internal:seed', true);
  }

  /**
   * Update existing records in the database.
   */
  private function updateRecords(): void
  {
    // First, get all existing records
    $existingPaths = $this->getAllSchemaPaths();
    $existingRecords = $this->blueprint->dbGetMany('blueprint', $existingPaths);

    $recordsToUpdate = [];

    foreach ($this->schema as $category => $values) {
      $categoryRecords = $this->buildUpdateRecords($category, $values, $existingRecords);
      $recordsToUpdate = array_merge($recordsToUpdate, $categoryRecords);
    }

    if (!empty($recordsToUpdate)) {
      $this->blueprint->dbSetMany('blueprint', $recordsToUpdate);
    }
  }

  /**
   * Build records array for a category recursively.
   */
  private function buildCategoryRecords(string $category, array $values, string $prefix = ''): array
  {
    $records = [];

    foreach ($values as $key => $config) {
      $path = $prefix ? "{$prefix}:{$key}" : "{$category}:{$key}";

      if (is_array($config) && isset($config['type'])) {
        // This is a leaf node with a value to seed
        if ($config['default'] !== null) {
          $records[$path] = $config['default'];
        }
      } else {
        // This is a nested category
        $records = array_merge($records, $this->buildCategoryRecords($category, $config, $path));
      }
    }

    return $records;
  }

  /**
   * Build update records array for a category recursively.
   */
  private function buildUpdateRecords(
    string $category,
    array $values,
    array $existingRecords,
    string $prefix = ''
  ): array {
    $records = [];

    foreach ($values as $key => $config) {
      $path = $prefix ? "{$prefix}:{$key}" : "{$category}:{$key}";

      if (is_array($config) && isset($config['type'])) {
        // This is a leaf node - check if it exists
        if (!isset($existingRecords[$path]) && $config['default'] !== null) {
          $records[$path] = $config['default'];
        }
      } else {
        // This is a nested category
        $records = array_merge($records, $this->buildUpdateRecords($category, $config, $existingRecords, $path));
      }
    }

    return $records;
  }

  /**
   * Get all possible paths from the schema.
   */
  private function getAllSchemaPaths(): array
  {
    $paths = [];

    foreach ($this->schema as $category => $values) {
      $paths = array_merge($paths, $this->extractPaths($category, $values));
    }

    return $paths;
  }

  /**
   * Extract all possible paths from a category recursively.
   */
  private function extractPaths(string $category, array $values, string $prefix = ''): array
  {
    $paths = [];

    foreach ($values as $key => $config) {
      $path = $prefix ? "{$prefix}:{$key}" : "{$category}:{$key}";

      if (is_array($config) && isset($config['type'])) {
        $paths[] = $path;
      } else {
        $paths = array_merge($paths, $this->extractPaths($category, $config, $path));
      }
    }

    return $paths;
  }
}
