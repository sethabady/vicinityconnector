codeunit 50877 "Vicinity IW Overrides"
{
    [EventSubscriber(ObjectType::Codeunit, 23044908, 'OnBeforeProcessEvent', '', true, true)]
    local procedure HandleOnBeforeProcessEvent(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    begin
        if piEventID = 801 then begin
            AutoGenerateLotNumber(precEventParams, pbtxtOutput, pbOverrideWHI);
        end;
    end;

    local procedure AutoGenerateLotNumber(var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    var
        lcodItemNumber: Code[20];
        lcodVariantCode: Code[10];
        lcodLotNumber: Code[50];
        lrecIWBatchLotNumber: Record "VIC IW Batch Lot Number";
        lrecIWBatchTransaction: Record "VIC IW Batch Transaction";
        lrecIWBatchOutput: Record "VIC IW Batch Output";
        liTransactionCount: Integer;

    begin
        if precEventParams.getValueAsBool('global.vicinity_lot_handler') then begin
            // Get the batch output record for this line.
            lrecIWBatchOutput.SetRange(BatchNumber, precEventParams.GetExtendedValue('global.batchnumber'));
            lrecIWBatchOutput.SetRange(LineIdNumber, precEventParams.getValueAsInt('global.lineidnumber'));
            if not lrecIWBatchOutput.FindFirst() then
                Error('Unable to find Batch Output record for Batch %1 Line %2', precEventParams.GetExtendedValue('global.batch_number'), precEventParams.getValueAsInt('global.lineidnumber'));

            // How many transaction ecords have we assigned to this line?
            lrecIWBatchTransaction.Reset();
            lrecIWBatchLotNumber.Reset();
            lrecIWBatchTransaction.SetFilter(LineIdNumber, Format(precEventParams.getValueAsInt('global.lineidnumber')));
            liTransactionCount := lrecIWBatchTransaction.Count();
            lrecIWBatchLotNumber.SetFilter(SequenceNumber, Format(liTransactionCount));
            if lrecIWBatchLotNumber.FindFirst() then
                lcodLotNumber := lrecIWBatchLotNumber.LotNumber
            else
                lcodLotNumber := lrecIWBatchOutput.LotNumber; // fallback to the lot number on the batch output line

            lcodItemNumber := CopyStr(precEventParams.GetExtendedValue('item_number'), 1, MaxStrLen(lcodItemNumber));
            lcodVariantCode := CopyStr(precEventParams.GetExtendedValue('variant_code'), 1, MaxStrLen(lcodVariantCode));
            pbtxtOutput.AddText(StrSubstNo('<VALUE>%1</VALUE>', lcodLotNumber));
            pbOverrideWHI := true; // indicates to WHI that we have handled the event
        end;
    end;
}

