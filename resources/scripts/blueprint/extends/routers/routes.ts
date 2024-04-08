import React from 'react';

/* blueprint/import */

interface RouteDefinition {
  path: string;
  name: string | undefined;
  component: React.ComponentType;
  exact?: boolean;
  adminOnly: boolean | false;
  identifier: string;
}
interface ServerRouteDefinition extends RouteDefinition {
  permission: string | string[] | null;
}
interface Routes {
  account: RouteDefinition[];
  server: ServerRouteDefinition[];
}

export default {
  account: [
    /* routes/account */
  ],
  server: [
    /* routes/server */
  ],
} as Routes;
