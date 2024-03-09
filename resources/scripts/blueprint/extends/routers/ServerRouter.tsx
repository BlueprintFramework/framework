import React from 'react';
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

export const NavigationLinks = () => {
  const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
  const serverEgg = ServerContext.useStoreState((state) => state.server.data?.eggId);
  const match = useRouteMatch<{ id: string }>();
  const to = (value: string, url = false) => {
    if (value === '/') {
      return url ? match.url : match.path;
    }
    return `${(url ? match.url : match.path).replace(/\/*$/, '')}/${value.replace(/^\/+/, '')}`;
  };

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
        )
      }

      {/* Blueprint routes */}
      {blueprintRoutes.server.length > 0 && blueprintRoutes.server
        .filter((route) => !!route.name)
        .filter((route) => route.adminOnly ? rootAdmin : true)
        .filter((route) => route.eggs && serverEgg ? route.eggs.includes(serverEgg) : true )
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
        )
      }

    </>
  );
};

export const NavigationRouter = () => {
  const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
  const serverEgg = ServerContext.useStoreState((state) => state.server.data?.eggId);
  const match = useRouteMatch<{ id: string }>();
  const to = (value: string, url = false) => {
    if (value === '/') {
      return url ? match.url : match.path;
    }
    return `${(url ? match.url : match.path).replace(/\/*$/, '')}/${value.replace(/^\/+/, '')}`;
  };

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
          {blueprintRoutes.server.length > 0 && blueprintRoutes.server
            .filter((route) => route.adminOnly ? rootAdmin : true)
            .filter((route) => route.eggs && serverEgg ? route.eggs.includes(serverEgg) : true )
            .map(({ path, permission, component: Component }) => (
              <PermissionRoute key={path} permission={permission} path={to(path)} exact>
                <Spinner.Suspense>
                  <Component />
                </Spinner.Suspense>
              </PermissionRoute>
            ))
          }

          <Route path={'*'} component={NotFound} />
        </Switch>
      </TransitionRouter>
    </>
  );
};