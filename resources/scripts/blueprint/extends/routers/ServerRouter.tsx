import React, { useState, useEffect } from 'react';
import { NavLink, Route, Switch, useRouteMatch } from 'react-router-dom';
import TransitionRouter from '@/TransitionRouter';
import PermissionRoute from '@/components/elements/PermissionRoute';
import Can from '@/components/elements/Can';
import Spinner from '@/components/elements/Spinner';
import { NotFound } from '@/components/elements/ScreenBlock';
import { useLocation } from 'react-router';
import { useStoreState } from 'easy-peasy';
import { ServerContext } from '@/state/server';

import routes from '@/routers/routes';
import blueprintRoutes from './routes';

const blueprintExtensions = [...new Set(blueprintRoutes.server.map((route) => route.identifier))];

/**
 * Get the route egg IDs for each extension with server routes.
 */
const useExtensionEggs = () => {
  const [extensionEggs, setExtensionEggs] = useState<{ [x: string]: string[] }>(
    blueprintExtensions.reduce((prev, current) => ({ ...prev, [current]: ['-1'] }), {})
  );

  useEffect(() => {
    (async () => {
      const newEggs: { [x: string]: string[] } = {};
      for (const id of blueprintExtensions) {
        const resp = await fetch(`/api/client/extensions/blueprint/eggs?${new URLSearchParams({ id })}`);
        newEggs[id] = (await resp.json()) as string[];
      }
      setExtensionEggs(newEggs);
    })();
  }, []);

  return extensionEggs;
};

export const NavigationLinks = () => {
  const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
  const serverEgg = ServerContext.useStoreState((state) => state.server.data?.BlueprintFramework.eggId);
  const match = useRouteMatch<{ id: string }>();
  const to = (value: string, url = false) => {
    if (value === '/') {
      return url ? match.url : match.path;
    }
    return `${(url ? match.url : match.path).replace(/\/*$/, '')}/${value.replace(/^\/+/, '')}`;
  };
  const extensionEggs = useExtensionEggs();

  return (
    <>
      {/* Pterodactyl routes */}
      {routes.server
        .filter((route) => !!route.name)
        .map((route) =>
          route.permission ? (
            <Can key={route.path} action={route.permission} matchAny>
              <NavLink to={to(route.path, true)} exact={route.exact}>
                {route.name}
              </NavLink>
            </Can>
          ) : (
            <NavLink key={route.path} to={to(route.path, true)} exact={route.exact}>
              {route.name}
            </NavLink>
          )
        )}

      {/* Blueprint routes */}
      {blueprintRoutes.server.length > 0 &&
        blueprintRoutes.server
          .filter((route) => !!route.name)
          .filter((route) => (route.adminOnly ? rootAdmin : true))
          .filter((route) =>
            extensionEggs[route.identifier].includes('-1')
              ? true
              : extensionEggs[route.identifier].find((id) => id === serverEgg?.toString())
          )
          .map((route) =>
            route.permission ? (
              <Can key={route.path} action={route.permission} matchAny>
                <NavLink to={to(route.path, true)} exact={route.exact}>
                  {route.name}
                </NavLink>
              </Can>
            ) : (
              <NavLink key={route.path} to={to(route.path, true)} exact={route.exact}>
                {route.name}
              </NavLink>
            )
          )}
    </>
  );
};

export const NavigationRouter = () => {
  const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
  const serverEgg = ServerContext.useStoreState((state) => state.server.data?.BlueprintFramework.eggId);
  const match = useRouteMatch<{ id: string }>();
  const to = (value: string, url = false) => {
    if (value === '/') {
      return url ? match.url : match.path;
    }
    return `${(url ? match.url : match.path).replace(/\/*$/, '')}/${value.replace(/^\/+/, '')}`;
  };
  const extensionEggs = useExtensionEggs();

  const location = useLocation();
  return (
    <>
      <TransitionRouter>
        <Switch location={location}>
          {/* Pterodactyl routes */}
          {routes.server.map(({ path, permission, component: Component }) => (
            <PermissionRoute key={path} permission={permission} path={to(path)} exact>
              <Spinner.Suspense>
                <Component />
              </Spinner.Suspense>
            </PermissionRoute>
          ))}

          {/* Blueprint routes */}
          {blueprintRoutes.server.length > 0 &&
            blueprintRoutes.server
              .filter((route) => (route.adminOnly ? rootAdmin : true))
              .filter((route) =>
                extensionEggs[route.identifier].includes('-1')
                  ? true
                  : extensionEggs[route.identifier].find((id) => id === serverEgg?.toString())
              )
              .map(({ path, permission, component: Component }) => (
                <PermissionRoute key={path} permission={permission} path={to(path)} exact>
                  <Spinner.Suspense>
                    <Component />
                  </Spinner.Suspense>
                </PermissionRoute>
              ))}

          <Route path={'*'} component={NotFound} />
        </Switch>
      </TransitionRouter>
    </>
  );
};
