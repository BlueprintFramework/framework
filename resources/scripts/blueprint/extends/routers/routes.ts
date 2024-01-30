import React from 'react';

/* blueprint/import */

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
    {/* routes/account */}
  ],
  server: [
    {/* routes/server */}
  ],
} as Routes;
