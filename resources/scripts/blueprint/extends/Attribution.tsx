import React from 'react';
import { useStoreState } from 'easy-peasy';
import { ApplicationStore } from '@/state';

export default () => {
  const disable_attribution = useStoreState((state: ApplicationStore) => state.settings.data!.blueprint.disable_attribution);

  return (
    <>
      {!disable_attribution && (
        <>
          <span className={"mx-2"}>
            •
          </span>

          <a
            rel={'noopener nofollow noreferrer'}
            href={'https://blueprint.zip'}
            target={'_blank'}
            className={`no-underline text-neutral-500 hover:text-neutral-300`}
          >
            Blueprint
          </a>
          &nbsp;&copy; 2023 - {new Date().getFullYear()}
        </>
      )}
    </>
  );
};
