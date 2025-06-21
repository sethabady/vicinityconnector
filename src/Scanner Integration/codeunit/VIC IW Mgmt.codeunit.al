/// <summary>
/// Codeunit WHI Production Mgmt. (ID 23044922).
/// </summary>
codeunit 50900 "VIC IW Mgmt."
{
    TableNo = "IWX Event Param";

    trigger OnRun()
    var
        ltxtOutputText: BigText;
        liEventID: Integer;
        losReturnMessage: OutStream;
    begin
        liEventID := Rec.getEvent();
        executeEvent(liEventID, Rec, ltxtOutputText);
        Rec."Extensibility Blob".CreateOutStream(losReturnMessage, TextEncoding::UTF16);
        ltxtOutputText.Write(losReturnMessage);
        Rec.Modify();
    end;

    /// <summary>
    /// Execute the appropriate procedure based on the event id.
    /// </summary>
    /// <param name="piEventID"></param>
    /// <param name="ptrecEventParams"></param>
    /// <param name="pbsOutput"></param>
    procedure executeEvent(piEventID: Integer; var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    begin
        recWHISetup.Get();
        iEventID := piEventID;
        case piEventID of
            98000:
                getCompletionBatchList(ptrecEventParams, pbsOutput);
            98001:
                refreshCompletionBatchItems(ptrecEventParams, pbsOutput);
            98002:
                refreshVicinityBatchesToScan(ptrecEventParams, pbsOutput);
            98012:
                refreshIWBatchesToScan(ptrecEventParams, pbsOutput);
            98003:
                refreshConsumptionBatchItems(ptrecEventParams, pbsOutput);
        // 98010:
        //     GetDocumentList(ptrecEventParams, pbsOutput);
        end;
    end;

    local procedure refreshIWBatchesToScan(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        VICWebServiceInterface: Codeunit "VIC Web Api";
        VicinitySetup: Record "VIC Connector Setup";
        lcodUser: Code[50];

        lrecConfig: Record "WHI Device Configuration";
        lrecIWBatch: Record "VIC IW Batch";
//        ltrecIWBatch: Record "VIC IW Batch" temporary;
        lrrefIWBatchRef: RecordRef;


        lcuDataSetTools: Codeunit "WHI Dataset Tools";
        ldnOutput: TextBuilder;
        lsFilter: Text;
        liDocCounter: Integer;
        lcodOptionalItem: Code[20];
        lbOnlyAssignedDocs: Boolean;
        liMaxDocList: Integer;
        liLineCounter: Integer;

    begin
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(VicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));

        // Populate "VIC IW Batch" from Vicinity web services.
         VICWebServiceInterface.OnFetchIWBatch(lcodUser);

        lrecIWBatch.Reset();
        lrrefIWBatchRef.GetTable(lrecIWBatch);
        if (lrrefIWBatchRef.FindFirst()) then;

        lcuDataSetTools.BuildLinesOnlyDataset(
          iEventID,
          lrrefIWBatchRef,
          false,
          ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());
        cuActivityLogMgt.logActivity(ptrecEventParams);
    end;


    local procedure refreshVicinityBatchesToScan(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        VICWebServiceInterface: Codeunit "VIC Web Api";
        VicinitySetup: Record "VIC Connector Setup";
        lcodUser: Code[50];

        lrecConfig: Record "WHI Device Configuration";
        lrecDocList: Record "VIC Batch To Scan";
        ltrecDocList: Record "VIC Batch To Scan" temporary;

        lcuDataSetTools: Codeunit "WHI Dataset Tools";
        lrrefDocListRef: RecordRef;
        ldnOutput: TextBuilder;
        lsFilter: Text;
        liDocCounter: Integer;
        lcodOptionalItem: Code[20];
        lbOnlyAssignedDocs: Boolean;
        liMaxDocList: Integer;
        liLineCounter: Integer;

    begin
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(VicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));

        // Populate "VIC Batch To Scan" from Vicinity web services.
        VICWebServiceInterface.OnFetchBatchSummaries(lcodUser);

//         lrecDocList.Reset();

//         // Iterate through "VIC Batch To Scan" and populate "WHI Document List Buffer".
//         if (lrecDocList.FindSet(false)) then
//             repeat
//                 ltrecDocList.Init();
//                 liLineCounter += 1;
//                 ltrecDocList."Entry No." := liLineCounter;
//                 ltrecDocList."Source Table" := 50801;
//                 ltrecDocList."Reference No." := lrecDocList.BatchNumber;
//                 ltrecDocList."Document No." := lrecDocList.BatchNumber;
//                 ltrecDocList."No." := lrecDocList.BatchNumber;
//                 ltrecDocList."Custom Text 1" := lrecDocList.FacilityId;
//                 ltrecDocList.Insert();
//             until (lrecDocList.Next() = 0);
//         ltrecDocList.Reset();

//         // Get reference to the newly populated "WHI Document List Buffer".
//         lrrefDocListRef.GetTable(ltrecDocList);
//         if (lrrefDocListRef.FindFirst()) then;

// //        lcuDatasetTools.BuildLineTableEmbedRes(iEventID, lrrefDocListRef, false, ldnOutput);

//         lcuDataSetTools.BuildLinesOnlyDataset(
//           98002,
//           lrrefDocListRef,
//           false,
//           ldnOutput);

//         //Error(ldnOutput.ToText());

//         pbsOutput.AddText(ldnOutput.ToText());
    end;

    local procedure refreshCompletionBatchItems(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        VICWebServiceInterface: Codeunit "VIC Web Api";
        VicinitySetup: Record "VIC Connector Setup";
        lsFacilityId: Text;
        lsBatchNumber: Text;
        lcodUser: Code[50];
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(VicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        lsFacilityId := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lsFacilityId));
        lsBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('batch_number'), 1, MaxStrLen(lsBatchNumber));
        VICWebServiceInterface.OnFetchBatchEndItems(lsFacilityId, lsBatchNumber, '');
    end;

    local procedure refreshConsumptionBatchItems(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        VICWebServiceInterface: Codeunit "VIC Web Api";
        VicinitySetup: Record "VIC Connector Setup";
        lsFacilityId: Text;
        lsBatchNumber: Text;
        lcodUser: Code[50];
    begin
        if not VicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(VicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lsFacilityId := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lsFacilityId));
        lsBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('batch_number'), 1, MaxStrLen(lsBatchNumber));
        VICWebServiceInterface.OnFetchBatchConsumptions(lsFacilityId, lsBatchNumber, lcodUser);
    end;

    //<FUNC>
    //  Gets the list of batches for completion scans. Max records returned configured by whi setup.
    //</FUNC>
    local procedure getCompletionBatchList(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecWHISetup: Record "WHI Setup";
        lcuDatasetTools: Codeunit "WHI Dataset Tools";
        lrrefItemRef: RecordRef;
        ldnOutput: TextBuilder;
        lsFilter: Text;
        liMaxRecordCount: Integer;
        liRecordCounter: Integer;
        lbHandled: Boolean;

        lrecVBatchToScan: Record "VIC Batch To Scan";
        ltrecVBatchToScan: Record "VIC Batch To Scan" temporary;
        lrrefVBatchToScanRef: RecordRef;

        lrrefWriter: RecordRef;


    begin

        lrecWHISetup.Get();
        liMaxRecordCount := lrecWHISetup."Document Max List";
        if liMaxRecordCount = 0 then
            liMaxRecordCount := 999999;

        OnBeforeGetCompletionBatchList(ptrecEventParams, lsFilter, lrecVBatchToScan, lbHandled);

        if lrecVBatchToScan.FindSet(false) then
            repeat
            until (lrecVBatchToScan.Next() = 0);


        lrrefVBatchToScanRef.GetTable(lrecVBatchToScan);
        if (lrrefVBatchToScanRef.FindFirst()) then;




#pragma warning disable AA0217
        ldnOutput.Append(StrSubstNo('<DATASET><TABLE id="header" eventid="%1" tableid="%2"><COLS>', iEventID, DATABASE::"VIC Batch To Scan"));
#pragma warning restore AA0217
        cuCommonFuncs.initializeColumns(true);
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC Batch To Scan");
        ldnOutput.Append('</COLS><ROWS><R><FIELDS>');
        lrrefWriter.GetTable(lrecVBatchToScan);
        cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefWriter, iEventID, '');
        ldnOutput.Append('</FIELDS></R></ROWS>');
        ldnOutput.Append('</TABLE>');
        ldnOutput.Append('</DATASET>');



        //      lcuDataSetTools.BuildLineTableWithMax(iEventID, lrrefVBatchToScanRef, ldnOutput, liMaxRecordCount);

        //      lcuDataSetTools.BuildLinesOnlyDataset(iEventID, lrrefVBatchToScanRef, false, ldnOutput);


        // lrrefVBatchOutputToScanRef.GetTable(lrecVBatchOutputToScan);
        // if (lrrefVBatchOutputToScanRef.FindFirst()) then;
        // lcuDataSetTools.BuildLineTableWithMax(iEventID, lrrefVBatchOutputToScanRef, ldnOutput, liMaxRecordCount);


        // if lbHandled then begin
        //     lrrefItemRef.GetTable(lrecItem);
        //     if (lrrefItemRef.FindFirst()) then;
        //     lcuDataSetTools.BuildLineTableWithMax(iEventID, lrrefItemRef, ldnOutput, liMaxRecordCount);
        // end
        // else
        //     if lsFilter <> '' then begin
        //         lrecVBatchOutputToScan.SetFilter("BatchNumber", lsFilter);
        //         liRecordCounter := 0;
        //         if lrecVBatchOutputToScan.FindSet(false) then
        //             repeat
        //                 ltrecVBatchOutputToScan := lrecVBatchOutputToScan;
        //                 ltrecVBatchOutputToScan.Insert();
        //                 liRecordCounter += 1;
        //             until ((lrecVBatchOutputToScan.Next() = 0) or (liRecordCounter >= liMaxRecordCount));

        //         // if ((liRecordCounter < liMaxRecordCount) and (lsFilter <> '')) then begin
        //         //     lrecItem.SetRange("No.");
        //         //     lrecItem.SetFilter("Search Description", lsFilter);
        //         //     if lrecItem.FindSet(false) then
        //         //         repeat
        //         //             ltrecItem := lrecItem;
        //         //             if ltrecItem.Insert() then
        //         //                 liRecordCounter += 1;
        //         //         until ((lrecItem.Next() = 0) or (liRecordCounter >= liMaxRecordCount))
        //         // end;

        //         ltrecVBatchOutputToScan.Reset();
        //         lrrefVBatchOutputToScanRef.GetTable(ltrecVBatchOutputToScan);
        //         if (lrrefVBatchOutputToScanRef.FindFirst()) then;

        //         lcuDatasetTools.BuildLinesOnlyDataset(
        //             iEventID,
        //             lrrefVBatchOutputToScanRef,
        //             false,
        //             ldnOutput);
        //     end
        //     else begin
        //         lrrefVBatchOutputToScanRef.GetTable(lrecVBatchOutputToScan);
        //         if (lrrefVBatchOutputToScanRef.FindFirst()) then;
        //         lcuDataSetTools.BuildLineTableWithMax(iEventID, lrrefVBatchOutputToScanRef, ldnOutput, liMaxRecordCount);
        //     end;

        pbsOutput.AddText(ldnOutput.ToText());
        //     cuActivityLogMgt.logActivity(ptrecEventParams);


        //cuCommonFuncs.generateSuccessReturn('', pbsOutput);

        // Error(Format(pbsOutput));

    end;






    // codeunit 50900 "VIC IW Handler"
    // {
    //     trigger OnRun()
    //     begin
    //     end;

    // [EventSubscriber(ObjectType::Codeunit, 23044908, 'OnBeforeProcessEvent', '', true, true)]
    // local procedure OnBeforeProcessEventSubscriber(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    // var
    //     lcuWHICommon: CodeUnit "WHI Common Functions";
    // begin
    //     case piEventID of
    //         21000:
    //             Test(piEventID, precEventParams, pbtxtOutput, pbOverrideWHI);
    //     end;
    // end;

    // local procedure Test(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    // var
    //     VicWebService: Codeunit "VIC Web Api";
    // begin
    //     pbOverrideWHI := true;
    //     VicWebService.OnFetchBatchSummaries();




    // end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeGetCompletionBatchList(var ptrecEventParams: Record "IWX Event Param" temporary; var psFilter: Text; var precItem: Record "VIC Batch To Scan"; var pbHandled: Boolean)
    begin
    end;


    var
        recWHISetup: Record "WHI Setup";
        cuCommonFuncs: Codeunit "WHI Common Functions";
        cuIWXCommon: Codeunit "IWX Common Base";
        cuPrintingMgmt: Codeunit "WHI Printing Mgmt.";
        cuActivityLogMgt: Codeunit "WHI Activity Log Mgmt.";
        cuRegistrationMgmt: Codeunit "WHI Registration Mgmt.";
        iEventID: Integer;
        tcColItemNumberLbl: Label 'Item No.';
        tcColDescriptionLbl: Label 'Description';
        tcColQuantityLbl: Label 'Quantity';
        tcColUOMLbl: Label 'UOM';
        tcColVariantLbl: Label 'Variant';
        tcColLotNumberLbl: Label 'Lot No.';
        tcColBinLbl: Label 'Bin';

}
