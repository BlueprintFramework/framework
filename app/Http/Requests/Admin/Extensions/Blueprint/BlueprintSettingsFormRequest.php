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
            'placeholder:1' => 'string',
            'placeholder:2' => 'string',
            'placeholder:3' => 'string',
        ];
    }

    public function attributes(): array
    {
        return [
            'placeholder:1' => 'placeholder',
            'placeholder:2' => 'placeholder',
            'placeholder:3' => 'placeholder',
        ];
    }
}
