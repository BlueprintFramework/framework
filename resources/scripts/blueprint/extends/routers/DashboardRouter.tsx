import React from 'react';
import { NavLink, Route, Switch } from 'react-router-dom';
import { useLocation } from 'react-router';
import { NotFound } from '@/components/elements/ScreenBlock';
import TransitionRouter from '@/TransitionRouter';
import DashboardContainer from '@/components/dashboard/DashboardContainer';
import Spinner from '@/components/elements/Spinner';

import routes from '@/routers/routes';
import blueprintRoutes from './routes';

export const NavigationLinks = () => {
  return (
    <>

      {/* Pterodactyl routes */}
      {routes.account
        .filter((route) => !!route.name)
        .map(({ path, name, exact = false }) => (
          <NavLink key={path} to={`/account/${path}`.replace('//', '/')} exact={exact}>
            {name}
          </NavLink>
        ))}

      {/* Blueprint routes */}
      {blueprintRoutes.account
        .filter((route) => !!route.name)
        .map(({ path, name, exact = false }) => (
          <NavLink key={path} to={`/account/${path}`.replace('//', '/')} exact={exact}>
            {name}
          </NavLink>
        ))}

    </>
  );
};

export const NavigationRouter = () => {
  const location = useLocation();
  return (
    <>
      <TransitionRouter>
        <React.Suspense fallback={<Spinner centered />}>
          <Switch location={location}>
            <Route path={'/'} exact>
              <DashboardContainer />
            </Route>

            {/* Pterodactyl routes */}
            {routes.account.map(({ path, component: Component }) => (
              <Route key={path} path={`/account/${path}`.replace('//', '/')} exact>
                <Component />
              </Route>
            ))}

            {/* Blueprint routes */}
            {blueprintRoutes.account.map(({ path, component: Component }) => (
              <Route key={path} path={`/account/${path}`.replace('//', '/')} exact>
                <Component />
              </Route>
            ))}
            
            <Route path={'*'}>
              <NotFound />
            </Route>
          </Switch>
        </React.Suspense>
      </TransitionRouter>
    </>
  );
};