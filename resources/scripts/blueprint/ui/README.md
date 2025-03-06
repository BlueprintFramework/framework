# Blueprint UI

Blueprint UI allows extensions to use versatile, easy to theme and powerful components that match the look of Pterodactyl's own components. Blueprint's components library can be called using `@blueprint/ui/path/to/component`.

Pterodactyl's own components and the ones offered in Blueprint UI can look nearly identical, with added features on the Blueprint UI counterparts.

## Components

- [x] [`UiBadge`](#badge)
- [x] `UiAlert`
- [x] `UiDivider`
- [ ] `UiButton`
- [ ] `UiCard`
- [ ] `UiModal`
- [ ] `UiTabs`
- [ ] `UiPagination`
- [ ] `UiColorpicker`
- [ ] `UiDropdown`
- [ ] `UiAccordion`
- [ ] `UiSlider`
- [ ] `UiInput`
- [ ] `UiSwitch`
- [ ] `UiLink`
- [ ] `UiIcon`

### Badge

```tsx
import { UiBadge } from '@blueprint/ui';

export default () => {
  return (
    <>
      <UiBadge>Hello, world!</UiBadge>
    </>
  );
};
```

## Disclaimer

Features documented in this file are highly subject to change, wait for a stable Blueprint release to be released first. This documentation will probably move over to [Blueprint's website](https://blueprint.zip) at a later date.
