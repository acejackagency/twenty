import { lastShowPageRecordIdState } from '@/object-record/record-field/ui/states/lastShowPageRecordId';
import { useRecordIndexTableQuery } from '@/object-record/record-index/hooks/useRecordIndexTableQuery';
import { RECORD_TABLE_ROW_HEIGHT } from '@/object-record/record-table/constants/RecordTableRowHeight';
import { useRecordTableContextOrThrow } from '@/object-record/record-table/contexts/RecordTableContext';
import { useScrollTableToPosition } from '@/object-record/record-table/hooks/useScrollTableToPosition';
import { isNonEmptyString } from '@sniptt/guards';
import { useEffect, useState } from 'react';
import { useRecoilState } from 'recoil';

export const RecordTableNoRecordGroupScrollToPreviousRecordEffect = () => {
  const { objectNameSingular } = useRecordTableContextOrThrow();

  const { records } = useRecordIndexTableQuery(objectNameSingular);

  const [lastShowPageRecordId] = useRecoilState(lastShowPageRecordIdState);

  const [hasInitializedScroll, setHasInitializedScroll] = useState(false);

  const { scrollTableToPosition } = useScrollTableToPosition();

  useEffect(() => {
    if (isNonEmptyString(lastShowPageRecordId)) {
      const isRecordAlreadyFetched = records.some(
        (record) => record.id === lastShowPageRecordId,
      );

      if (isRecordAlreadyFetched) {
        const recordPosition = records.findIndex(
          (record) => record.id === lastShowPageRecordId,
        );

        const positionInPx = recordPosition * RECORD_TABLE_ROW_HEIGHT;

        scrollTableToPosition({
          horizontalScrollInPx: 0,
          verticalScrollInPx: positionInPx,
        });

        setHasInitializedScroll(true);
      }
    }
  }, [
    hasInitializedScroll,
    lastShowPageRecordId,
    records,
    scrollTableToPosition,
  ]);

  return <></>;
};
