<?php

namespace Pterodactyl\Http\Requests\Admin\Extensions\Blueprint;

use Pterodactyl\Http\Requests\Admin\AdminFormRequest;

class BlueprintSettingsFormRequest extends AdminFormRequest
{
    /**
     * Return all the rules to apply to this request's data.
     */
    public function rules(): array
    {
        return [
            'placeholder' => 'string',
            'developer' => 'boolean',
        ];
    }

    public function attributes(): array
    {
        return [
            'placeholder' => 'placeholder',
            'developer' => 'developer',
        ];
    }
}
