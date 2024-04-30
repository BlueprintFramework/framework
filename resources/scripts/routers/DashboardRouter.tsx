import React from 'react';
import NavigationBar from '@/components/NavigationBar';
import SubNavigation from '@/components/elements/SubNavigation';
import { useLocation } from 'react-router';

import { NavigationLinks, NavigationRouter } from '@/blueprint/extends/routers/DashboardRouter';
import BeforeSubNavigation                   from '@/blueprint/components/Navigation/SubNavigation/BeforeSubNavigation';
import AdditionalAccountItems                from '@/blueprint/components/Navigation/SubNavigation/AdditionalAccountItems';
import AfterSubNavigation                    from '@/blueprint/components/Navigation/SubNavigation/AfterSubNavigation';

export default () => {
    const location = useLocation();

    return (
        <>
            <NavigationBar />
            {location.pathname.startsWith('/account') && (
                <SubNavigation id={'SubNavigation'}>
                    <BeforeSubNavigation />
                    <div>
                        <NavigationLinks />
                        <AdditionalAccountItems />
                    </div>
                    <AfterSubNavigation />
                </SubNavigation>
            )}
            <NavigationRouter />
        </>
    );
};
