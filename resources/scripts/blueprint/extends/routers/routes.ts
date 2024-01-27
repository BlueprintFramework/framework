import React from 'react';

/* blueprint/import */
import ExampleContainer from './ExampleComponent';

interface ExtendedRouteDefinition {
  path: string;
  name: string | undefined;
  component: React.ComponentType;
  exact?: boolean;
}
interface ExtendedServerRouteDefinition extends ExtendedRouteDefinition {
  permission: string | string[] | null;
}
interface Routes {
  account: ExtendedRouteDefinition[];
  server: ExtendedServerRouteDefinition[];
}

export default {
  account: [
    {
      path: '/example',
      name: 'Example',
      component: ExampleContainer,
    },
    {/* routes/account */}
  ],
  server: [
    {
      path: '/example',
      permission: null,
      name: 'Example',
      component: ExampleContainer,
    },
    {/* routes/server */}
  ],
} as Routes;
