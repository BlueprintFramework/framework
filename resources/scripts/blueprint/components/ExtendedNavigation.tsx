import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPuzzlePiece } from '@fortawesome/free-solid-svg-icons';
import Tooltip from '@/components/elements/tooltip/Tooltip';

export default () => {
  return (
    <>
      <Tooltip placement={'bottom'} content={'Example'}>
        <div className={'navigation-link'}>
          <FontAwesomeIcon icon={faPuzzlePiece} />
        </div>
      </Tooltip>
    </>
  );
};
