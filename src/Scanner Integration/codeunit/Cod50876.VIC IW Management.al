codeunit 50876 "Vicinity IW Management"
{
    TableNo = "IWX Event Param";

    trigger OnRun()
    var
        ltxtOutputText: BigText;
        liEventID: Integer;
        losReturnMessage: OutStream;
    begin
        liEventID := Rec.getEvent();
        this.ExecuteEvent(liEventID, Rec, ltxtOutputText);
        Rec."Extensibility Blob".CreateOutStream(losReturnMessage);
        ltxtOutputText.Write(losReturnMessage);
        Rec.Modify();
    end;

    procedure ExecuteEvent(piEventID: Integer; var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    begin
        iEventID := piEventID;

        case piEventID of
            2500000:
                this.GetVICOutputBatchList(ptrecEventParams, pbsOutput);
            2500001:
                this.GetVICOutputBatchDocument(ptrecEventParams, pbsOutput);
            2500002:
                this.UpdateVICOutputBatchCompleted(ptrecEventParams, pbsOutput);
            2500003:
                this.PostVICOutputBatch(ptrecEventParams, pbsOutput);
            2500010:
                this.GetVICInputBatchList(ptrecEventParams, pbsOutput);
            2500011:
                this.GetVICInputBatchDocument(ptrecEventParams, pbsOutput);
            2500012:
                this.UpdateVICInputBatchCompleted(ptrecEventParams, pbsOutput);
            2500013:
                this.PostVICConsumptionBatch(ptrecEventParams, pbsOutput);
        end;
    end;

    procedure GetVICOutputBatchList(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICOutputBatch: Record "VIC IW Batch";
        lrrefBatchRef: RecordRef;
        ldnOutput: TextBuilder;
        lsFilter: Text;
        lcodUser: Code[50];
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lsFilter := this.EscapeFilterString(ptrecEventParams.GetExtendedValue('filter'));
        this.UpdateVICBatches(lcodUser);

        // Restrict to the current scanner user.
        lrecVICOutputBatch.SetRange(User, lcodUser);

        if (lsFilter <> '') then
            lrecVICOutputBatch.SetFilter(BatchNumber, lsFilter);

        lrrefBatchRef.GetTable(lrecVICOutputBatch);
        if (lrrefBatchRef.FindFirst()) then;

        this.cuDataSetTools.BuildLinesOnlyDataset(
          this.iEventID,
          lrrefBatchRef,
          false,
          ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure GetVICInputBatchList(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICInputBatch: Record "VIC IW Batch";
        lrrefBatchRef: RecordRef;
        ldnOutput: TextBuilder;
        lsFilter: Text;
        lcodUser: Code[50];
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lsFilter := this.EscapeFilterString(ptrecEventParams.GetExtendedValue('filter'));

        this.UpdateVICBatches(lcodUser);

        // Restrict to the current scanner user.
        lrecVICInputBatch.SetRange(User, lcodUser);

        if (lsFilter <> '') then
            lrecVICInputBatch.SetFilter(BatchNumber, lsFilter);

        lrrefBatchRef.GetTable(lrecVICInputBatch);
        if (lrrefBatchRef.FindFirst()) then;

        this.cuDataSetTools.BuildLinesOnlyDataset(
          this.iEventID,
          lrrefBatchRef,
          false,
          ldnOutput);

        pbsOutput.AddText(ldnOutput.ToText());
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure GetVICOutputBatchDocument(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICOutputBatch: Record "VIC IW Batch";
        lrecVICOutoutBatchLine: Record "VIC IW Batch Output";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lrrefBatchRef: RecordRef;
        lrrefBatchLineRef: RecordRef;

        lrecReservationEntry: Record "Reservation Entry";

        lrecItem: Record Item;
        ldnOutput: TextBuilder;
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodUser: Code[50];
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('output_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        this.UpdateVicBatchOutputs(lcodFacilityID, lcodBatchNumber, lcodUser);

        lrecVICOutputBatch.Get(lcodUser, lcodFacilityID, lcodBatchNumber);
        lrecVICOutputBatch.SetRecFilter();
        lrrefBatchRef.GetTable(lrecVICOutputBatch);

        ldnOutput.Append('<DATASET>'); // start "header + line" dataset

        //
        // "header" table.
        //

        // The "id" must be called "header".   ****
        // This will be your batch info (tempalte, name, location, etc).
        // Change table to match your needs
        ldnOutput.Append(StrSubstNo('<TABLE id="header" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch"));

        //
        // "header" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch");
        ldnOutput.Append('</COLS>');

        //
        // "header" row (should only be one)
        //

        ldnOutput.Append('<ROWS><R><FIELDS>');

        cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefBatchRef, iEventID, '');
        ldnOutput.Append('</FIELDS></R></ROWS>');


        ldnOutput.Append('</TABLE>'); // end "header" table

        //
        // "line" table
        //

        // The "id" must be called "line".  ****
        // This will be your batch line info (line number, item, quantity, bin, etc).
        // Change table to match your needs  
        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch Output"));

        //
        // "line" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch Output");
        cuCommonFuncs.addDSTrackingColumnsDN(ldnOutput);
        ldnOutput.Append('</COLS>');


        //
        // "line" rows
        //


        ldnOutput.Append('<ROWS>'); // start "line" rows

        lrecVICOutoutBatchLine.SetRange(FacilityId, lcodFacilityID);
        lrecVICOutoutBatchLine.SetRange(BatchNumber, lcodBatchNumber);
        lrecVICOutoutBatchLine.SetRange(User, lcodUser);

        // loop through the lines and build up each row
        if (lrecVICOutoutBatchLine.FindSet(false)) then
            repeat
                ldnOutput.Append('<R>');  // start "line" row

                //
                // "line" fields
                //
                ldnOutput.Append('<FIELDS>');

                // Update each VIC IW Batch Output line with the calculated Quantity Remaining.
                cuCommonFuncs.setDSFieldOverrideValue(iEventID,
                '',
                DATABASE::"VIC IW Batch Output",
                lrecVICOutoutBatchLine.FieldNo("QuantityRemaining"),
                StrSubstNo('%1', (lrecVICOutoutBatchLine.QuantityRemaining)));

                lrrefBatchLineRef.GetTable(lrecVICOutoutBatchLine);
                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefBatchLineRef, iEventID, '');

                // add this so it knows what the item tracking code/values are for the line
                lrecItem.Get(lrecVICOutoutBatchLine.ComponentId);
                cuCommonFuncs.addDSTrackingFieldsDN(ldnOutput, lrecItem."Item Tracking Code");
                ldnOutput.Append('</FIELDS>');

                //
                // "line" item tracking entries
                //
                lrecVICBatchTransaction.SetRange(User, lcodUser);
                lrecVICBatchTransaction.SetRange(FacilityId, lcodFacilityID);
                lrecVICBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
                lrecVICBatchTransaction.SetRange(LineIdNumber, lrecVICOutoutBatchLine.LineIdNumber);

                //                 if not lrecVICBatchTransaction.FindSet(false) then begin
                //                     // Default an tracking entry.
                //                     lrecVICBatchTransaction.Init();
                //                     lrecVICBatchTransaction.User := lcodUser;
                //                     lrecVICBatchTransaction.FacilityId := lcodFacilityID;
                //                     lrecVICBatchTransaction.BatchNumber := lcodBatchNumber;
                //                     lrecVICBatchTransaction.LineIdNumber := lrecVICOutoutBatchLine.LineIdNumber;
                //                     lrecVICBatchTransaction.ComponentId := lrecVICOutoutBatchLine.ComponentId;
                //                     lrecVICBatchTransaction.LotNumber := lrecVICOutoutBatchLine.LotNumber; // 'TEST LOT NUMBER';
                // //                    lrecVICBatchTransaction.LotExpirationDate := ldtExpirationDate;
                //                     lrecVICBatchTransaction.Quantity := lrecVICOutoutBatchLine.QuantityRemaining;
                //                     lrecVICBatchTransaction.ConsumptionTransaction := false;
                //                     lrecVICBatchTransaction.Insert();
                //                 end;




                if lrecVICBatchTransaction.FindSet(false) then
                    repeat
                        // ensure these fields are all returned/added
                        // I've left them as mapped up to the standard reservatione entry table but if they don't apply to your scenario,
                        //   then maybe default to "0" for integers and "" for text
                        ldnOutput.Append('<LINE>');
                        ldnOutput.Append(StrSubstNo('<ENTRY_NUMBER>%1</ENTRY_NUMBER>', lrecVICBatchTransaction."Line No."));
                        ldnOutput.Append(StrSubstNo('<ITEM_NUMBER>%1</ITEM_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.ComponentId)));
                        ldnOutput.Append(StrSubstNo('<SERIAL_NUMBER>%1</SERIAL_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<SOURCE_ID>%1</SOURCE_ID>', lrecVICBatchTransaction.BatchNumber));
                        ldnOutput.Append(StrSubstNo('<SOURCE_REF_NUMBER>%1</SOURCE_REF_NUMBER>', 0));
                        ldnOutput.Append(StrSubstNo('<POSITIVE>%1</POSITIVE>', true));
                        ldnOutput.Append(StrSubstNo('<QTY_BASE>%1</QTY_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<LOT_NUMBER>%1</LOT_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.LotNumber)));
                        ldnOutput.Append(StrSubstNo('<PACKAGE_NUMBER>%1</PACKAGE_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<QTY_HANDLE_BASE>%1</QTY_HANDLE_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<QTY_PER_UOM>%1</QTY_PER_UOM>', 1));
                        ldnOutput.Append(StrSubstNo('<ITEM_TRACKING>%1</ITEM_TRACKING>', lrecVICBatchTransaction."Item Tracking".AsInteger()));
                        ldnOutput.Append(StrSubstNo('<EXP>%1</EXP>', lrecVICBatchTransaction.LotExpirationDate));
                        ldnOutput.Append('</LINE>');
                    until (lrecVICBatchTransaction.Next() = 0);
                ldnOutput.Append('</R>');  // end "line" row
            until (lrecVICOutoutBatchLine.Next() = 0);

        ldnOutput.Append('</ROWS>');    // end "line" rows
        ldnOutput.Append('</TABLE>');   // end "line" table
        ldnOutput.Append('</DATASET>'); // end header + line dataset
        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure GetVICInputBatchDocument(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICInputBatch: Record "VIC IW Batch";
        lrecVICInputBatchLine: Record "VIC IW Batch Consumption";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lrrefBatchRef: RecordRef;
        lrrefBatchLineRef: RecordRef;
        ldnOutput: TextBuilder;
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodUser: Code[50];
        lrecItem: Record Item;
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('input_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        this.UpdateVicBatchInputs(lcodFacilityID, lcodBatchNumber, lcodUser);

        lrecVICInputBatch.Get(lcodUser, lcodFacilityID, lcodBatchNumber);
        lrecVICInputBatch.SetRecFilter();
        lrrefBatchRef.GetTable(lrecVICInputBatch);

        ldnOutput.Append('<DATASET>'); // start "header + line" dataset

        //
        // "header" table.
        //

        // The "id" must be called "header".   ****
        // This will be your batch info (tempalte, name, location, etc).
        // Change table to match your needs
        ldnOutput.Append(StrSubstNo('<TABLE id="header" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch"));

        //
        // "header" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch");
        ldnOutput.Append('</COLS>');

        //
        // "header" row (should only be one)
        //

        ldnOutput.Append('<ROWS><R><FIELDS>');

        cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefBatchRef, iEventID, '');
        ldnOutput.Append('</FIELDS></R></ROWS>');


        ldnOutput.Append('</TABLE>'); // end "header" table

        //
        // "line" table
        //

        // The "id" must be called "line".  ****
        // This will be your batch line info (line number, item, quantity, bin, etc).
        // Change table to match your needs  
        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch Consumption"));

        //
        // "line" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch Consumption");
        cuCommonFuncs.addDSTrackingColumnsDN(ldnOutput);
        ldnOutput.Append('</COLS>');


        //
        // "line" rows
        //


        ldnOutput.Append('<ROWS>'); // start "line" rows

        lrecVICInputBatchLine.SetRange(FacilityId, lcodFacilityID);
        lrecVICInputBatchLine.SetRange(BatchNumber, lcodBatchNumber);

        // loop through the lines and build up each row
        if (lrecVICInputBatchLine.FindSet(false)) then
            repeat
                ldnOutput.Append('<R>');  // start "line" row

                //
                // "line" fields
                //
                ldnOutput.Append('<FIELDS>');

                // Update each VIC IW Batch Output line with the calculated Quantity Remaining.
                cuCommonFuncs.setDSFieldOverrideValue(iEventID,
                '',
                DATABASE::"VIC IW Batch Output",
                lrecVICInputBatchLine.FieldNo("QuantityRemaining"),
                StrSubstNo('%1', (lrecVICINputBatchLine.QuantityOrdered - lrecVICInputBatchLine.QuantityCompleted - lrecVICInputBatchLine.QuantityToComplete)));

                lrrefBatchLineRef.GetTable(lrecVICInputBatchLine);
                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefBatchLineRef, iEventID, '');

                // add this so it knows what the item tracking code/values are for the line
                lrecItem.Get(lrecVICInputBatchLine.ComponentId);
                cuCommonFuncs.addDSTrackingFieldsDN(ldnOutput, lrecItem."Item Tracking Code");
                ldnOutput.Append('</FIELDS>');

                //
                // "line" item tracking entries
                //
                lrecVICBatchTransaction.SetRange(User, lcodUser);
                lrecVICBatchTransaction.SetRange(FacilityId, lcodFacilityID);
                lrecVICBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
                lrecVICBatchTransaction.SetRange(LineIdNumber, lrecVICInputBatchLine.LineIdNumber);
                if lrecVICBatchTransaction.FindSet(false) then
                    repeat
                        // ensure these fields are all returned/added
                        // I've left them as mapped up to the standard reservatione entry table but if they don't apply to your scenario,
                        //   then maybe default to "0" for integers and "" for text
                        ldnOutput.Append('<LINE>');
                        ldnOutput.Append(StrSubstNo('<ENTRY_NUMBER>%1</ENTRY_NUMBER>', lrecVICBatchTransaction."Line No."));
                        ldnOutput.Append(StrSubstNo('<ITEM_NUMBER>%1</ITEM_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.ComponentId)));
                        ldnOutput.Append(StrSubstNo('<SERIAL_NUMBER>%1</SERIAL_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<SOURCE_ID>%1</SOURCE_ID>', lrecVICBatchTransaction.BatchNumber));
                        ldnOutput.Append(StrSubstNo('<SOURCE_REF_NUMBER>%1</SOURCE_REF_NUMBER>', 0));
                        ldnOutput.Append(StrSubstNo('<POSITIVE>%1</POSITIVE>', true));
                        ldnOutput.Append(StrSubstNo('<QTY_BASE>%1</QTY_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<LOT_NUMBER>%1</LOT_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.LotNumber)));
                        ldnOutput.Append(StrSubstNo('<PACKAGE_NUMBER>%1</PACKAGE_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<QTY_HANDLE_BASE>%1</QTY_HANDLE_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<QTY_PER_UOM>%1</QTY_PER_UOM>', 1));
                        ldnOutput.Append(StrSubstNo('<ITEM_TRACKING>%1</ITEM_TRACKING>', lrecVICBatchTransaction."Item Tracking".AsInteger()));
                        ldnOutput.Append(StrSubstNo('<EXP>%1</EXP>', lrecVICBatchTransaction.LotExpirationDate));
                        ldnOutput.Append('</LINE>');
                    until (lrecVICBatchTransaction.Next() = 0);
                ldnOutput.Append('</R>');  // end "line" row
            until (lrecVICInputBatchLine.Next() = 0);

        ldnOutput.Append('</ROWS>');    // end "line" rows
        ldnOutput.Append('</TABLE>');   // end "line" table
        ldnOutput.Append('</DATASET>'); // end header + line dataset
        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure UpdateVICOutputBatchCompleted(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        // VIC IW Batch Output is the line being scanned against.
        lrecVICIWBatchOutput: Record "VIC IW Batch Output";

        // VIC IW Batch Transaction contains the item tracking entries for the line.
        lrecVICIWBatchTransaction: Record "VIC IW Batch Transaction";

        lrecItem: Record Item;
        lrrefLineRef: RecordRef;
        ldnOutput: TextBuilder;
        ldtExpirationDate: Date;
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodLotNumber: Code[50];
        liLineIdNumber: Integer;
        ldPreviousQuantity: Decimal;
        ldQtyToComplete: Decimal;
        lcodUser: Code[50];
        lbreservation_added: Boolean;
        lbreservation_modified: Boolean;
        lbreservation_deleted: Boolean;
        lireservationEntryNumber: Integer;
        ldTotalQuantityToPost: Decimal;
        ldPreviousQuantityToPost: Decimal;
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('output_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        liLineIdNumber := ptrecEventParams.getValueAsInt('Line ID Number');
        lcodLotNumber := CopyStr(ptrecEventParams.GetExtendedValue('lot_number'), 1, MaxStrLen(lcodLotNumber));
        ldtExpirationDate := this.cuCommonFuncs.getExpirationDate(ptrecEventParams);
        ldQtyToComplete := ptrecEventParams.getValueAsDecimal('qty_to_complete');
        lbreservation_added := ptrecEventParams.getValueAsBool('reservation_added');
        lbreservation_modified := ptrecEventParams.getValueAsBool('reservation_modified');
        lbreservation_deleted := ptrecEventParams.getValueAsBool('reservation_deleted');
        lireservationEntryNumber := ptrecEventParams.getValueAsInt('reservation_entry_number');

        if not (lbreservation_added or lbreservation_modified or lbreservation_deleted) then
            exit;

        // Get the line we're scanning against.
        lrecVICIWBatchOutput.Get(lcodFacilityID, lcodBatchNumber, liLineIdNumber);

        // Get the sum of the item tracking entries against the line so multiple scans can be handled.
        lrecVICIWBatchTransaction.Reset();
        lrecVICIWBatchTransaction.SetCurrentKey(User, FacilityId, BatchNumber, LineIdNumber);
        lrecVICIWBatchTransaction.SetRange(User, lcodUser);
        lrecVICIWBatchTransaction.SetRange(FacilityId, lcodFacilityID);
        lrecVICIWBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
        lrecVICIWBatchTransaction.SetRange(LineIdNumber, liLineIdNumber);
        ldPreviousQuantityToPost := 0;
        if lrecVICIWBatchTransaction.FindSet(false) then
            repeat
                ldPreviousQuantityToPost += lrecVICIWBatchTransaction.Quantity;
            until (lrecVICIWBatchTransaction.Next() = 0);

        if lbreservation_deleted then begin
            if lrecVICIWBatchTransaction.get(lireservationEntryNumber) then begin
                lrecVICIWBatchTransaction.Delete();
            end
        end
        else if lbreservation_modified then begin
            if lrecVICIWBatchTransaction.get(lireservationEntryNumber) then begin
                lrecVICIWBatchTransaction.Quantity := ldQtyToComplete;
                lrecVICIWBatchTransaction.LotNumber := lcodLotNumber;
                lrecVICIWBatchTransaction.LotExpirationDate := ldtExpirationDate;
                lrecVICIWBatchTransaction.Modify();
            end
        end
        else if lbreservation_added then begin
            lrecVICIWBatchTransaction.Init();
            lrecVICIWBatchTransaction."Line No." := 0;
            lrecVICIWBatchTransaction.User := lcodUser;
            lrecVICIWBatchTransaction.FacilityId := lcodFacilityID;
            lrecVICIWBatchTransaction.BatchNumber := lcodBatchNumber;
            lrecVICIWBatchTransaction.LineIdNumber := liLineIdNumber;
            lrecVICIWBatchTransaction.ComponentId := lrecVICIWBatchOutput.ComponentId;
            lrecVICIWBatchTransaction.LotNumber := lcodLotNumber;
            lrecVICIWBatchTransaction.LotExpirationDate := ldtExpirationDate;
            lrecVICIWBatchTransaction.Quantity := ldQtyToComplete;
            lrecVICIWBatchTransaction.ConsumptionTransaction := false;
            if lrecVICIWBatchTransaction.Insert(false) then begin
                lireservationEntryNumber := lrecVICIWBatchTransaction."Line No.";
            end;
        end;

        lrecVICIWBatchTransaction.Reset();
        lrecVICIWBatchTransaction.SetCurrentKey(User, FacilityId, BatchNumber, LineIdNumber);
        lrecVICIWBatchTransaction.SetRange(User, lcodUser);
        lrecVICIWBatchTransaction.SetRange(FacilityId, lcodFacilityID);
        lrecVICIWBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
        lrecVICIWBatchTransaction.SetRange(LineIdNumber, liLineIdNumber);
        ldTotalQuantityToPost := 0;
        if lrecVICIWBatchTransaction.FindSet(false) then
            repeat
                ldTotalQuantityToPost += lrecVICIWBatchTransaction.Quantity;
            until (lrecVICIWBatchTransaction.Next() = 0);

        // Update the parent line (retrieved above).

        lrecVICIWBatchOutput.QuantityToComplete := ldTotalQuantityToPost;
        if lrecVICIWBatchOutput.QuantityOrdered - lrecVICIWBatchOutput.QuantityCompleted - ldTotalQuantityToPost > 0 then
            lrecVICIWBatchOutput.QuantityRemaining := lrecVICIWBatchOutput.QuantityOrdered - lrecVICIWBatchOutput.QuantityCompleted - ldTotalQuantityToPost
        else
            lrecVICIWBatchOutput.QuantityRemaining := 0;

        lrecVICIWBatchOutput.LotNumber := lcodLotNumber;
        lrecVICIWBatchOutput.ExpirationDate := ldtExpirationDate;
        lrecVICIWBatchOutput.Modify(true);

        lrecVICIWBatchOutput.SetRecFilter();
        lrrefLineRef.GetTable(lrecVICIWBatchOutput);

        ldnOutput.Append('<DATASET>');

        //        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch Output"));
        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', 2500001, DATABASE::"VIC IW Batch Output"));

        //
        // "line" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        //        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch Output");
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, 2500001, '', DATABASE::"VIC IW Batch Output");
        cuCommonFuncs.addDSTrackingColumnsDN(ldnOutput);
        ldnOutput.Append('</COLS>');

        //
        // "line" rows
        //

        ldnOutput.Append('<ROWS>'); // start "line" rows

        lrecVICIWBatchOutput.Reset();
        lrecVICIWBatchOutput.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
        lrecVICIWBatchOutput.SetRange(FacilityId, lcodFacilityID);
        lrecVICIWBatchOutput.SetRange(BatchNumber, lcodBatchNumber);
        lrecVICIWBatchOutput.SetRange(LineIdNumber, liLineIdNumber);

        // loop through the lines and build up each row
        if (lrecVICIWBatchOutput.FindSet(false)) then
            repeat
                ldnOutput.Append('<R>');  // start "line" row

                //
                // "line" fields
                //
                ldnOutput.Append('<FIELDS>');

                // you might have some existing code similar to this alredy - just move/replace this with that
                // change table to match
                cuCommonFuncs.setDSFieldOverrideValue(iEventID,
                '',
                DATABASE::"VIC IW Batch Output",
                lrecVICIWBatchOutput.FieldNo("QuantityRemaining"),
                StrSubstNo('%1', (lrecVICIWBatchOutput.QuantityOrdered - lrecVICIWBatchOutput.QuantityCompleted - lrecVICIWBatchOutput.QuantityToComplete)));


                //                lrrefLineRef.GetTable(lrecVICIWBatchOutput);
                //                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefLineRef, iEventID, '');
                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefLineRef, 2500001, '');

                // add this so it knows what the item tracking code/values are for the line
                lrecItem.Get(lrecVICIWBatchOutput.ComponentId);
                cuCommonFuncs.addDSTrackingFieldsDN(ldnOutput, lrecItem."Item Tracking Code");
                ldnOutput.Append('</FIELDS>');

                //
                // "line" item tracking entries
                //
                lrecVICIWBatchTransaction.Reset();
                lrecVICIWBatchTransaction.SetRange(User, lcodUser);
                lrecVICIWBatchTransaction.SetRange(FacilityId, lcodFacilityID);
                lrecVICIWBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
                lrecVICIWBatchTransaction.SetRange(LineIdNumber, lrecVICIWBatchOutput.LineIdNumber);

                if lrecVICIWBatchTransaction.FindSet(false) then
                    repeat
                        // ensure these fields are all returned/added
                        // I've left them as mapped up to the standard reservatione entry table but if they don't apply to your scenario,
                        //   then maybe default to "0" for integers and "" for text

                        ldnOutput.Append('<LINE>');
                        ldnOutput.Append(StrSubstNo('<ENTRY_NUMBER>%1</ENTRY_NUMBER>', lrecVICIWBatchTransaction."Line No."));
                        ldnOutput.Append(StrSubstNo('<ITEM_NUMBER>%1</ITEM_NUMBER>', cuCommonFuncs.escapeText(lrecVICIWBatchTransaction.ComponentId)));
                        ldnOutput.Append(StrSubstNo('<SERIAL_NUMBER>%1</SERIAL_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<SOURCE_ID>%1</SOURCE_ID>', lrecVICIWBatchTransaction.BatchNumber));
                        ldnOutput.Append(StrSubstNo('<SOURCE_REF_NUMBER>%1</SOURCE_REF_NUMBER>', 0));
                        ldnOutput.Append(StrSubstNo('<POSITIVE>%1</POSITIVE>', true));
                        ldnOutput.Append(StrSubstNo('<QTY_BASE>%1</QTY_BASE>', lrecVICIWBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<LOT_NUMBER>%1</LOT_NUMBER>', cuCommonFuncs.escapeText(lrecVICIWBatchTransaction.LotNumber)));
                        ldnOutput.Append(StrSubstNo('<PACKAGE_NUMBER>%1</PACKAGE_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<QTY_HANDLE_BASE>%1</QTY_HANDLE_BASE>', lrecVICIWBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<QTY_PER_UOM>%1</QTY_PER_UOM>', 1));
                        ldnOutput.Append(StrSubstNo('<ITEM_TRACKING>%1</ITEM_TRACKING>', lrecVICIWBatchTransaction."Item Tracking".AsInteger()));
                        ldnOutput.Append(StrSubstNo('<EXP>%1</EXP>', lrecVICIWBatchTransaction.LotExpirationDate));
                        ldnOutput.Append('</LINE>');

                    until (lrecVICIWBatchTransaction.Next() = 0);
                ldnOutput.Append('</R>');  // end "line" row

            until (lrecVICIWBatchOutput.Next() = 0);

        ldnOutput.Append('</ROWS>');    // end "line" rows
        ldnOutput.Append('</TABLE>');   // end "line" table
        ldnOutput.Append('</DATASET>');

        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch Output"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        ptrecEventParams.setValue('Previous Quantity', Format(ldPreviousQuantity));
        ptrecEventParams.setValue('New Quantity', Format(ldQtyToComplete));
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure UpdateVICInputBatchCompleted(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICConsumptionBatchLine: Record "VIC IW Batch Consumption";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lrecItem: Record Item;
        lrrefLineRef: RecordRef;
        ldnOutput: TextBuilder;
        ldtExpirationDate: Date;
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodLotNumber: Code[50];
        liLineIdNumber: Integer;
        ldPreviousQuantity: Decimal;
        ldQtyToComplete: Decimal;
        lcodUser: Code[50];
        lbreservation_added: Boolean;
        lbreservation_modified: Boolean;
        lbreservation_deleted: Boolean;
        lireservationEntryNumber: Integer;

        ldTotalQuantityToPost: Decimal;
    begin
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('input_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        liLineIdNumber := ptrecEventParams.getValueAsInt('Line ID Number');
        lcodLotNumber := CopyStr(ptrecEventParams.GetExtendedValue('lot_number'), 1, MaxStrLen(lcodLotNumber));
        ldtExpirationDate := this.cuCommonFuncs.getExpirationDate(ptrecEventParams);
        ldQtyToComplete := ptrecEventParams.getValueAsDecimal('qty_to_complete');
        lbreservation_added := ptrecEventParams.getValueAsBool('reservation_added');
        lbreservation_modified := ptrecEventParams.getValueAsBool('reservation_modified');
        lbreservation_deleted := ptrecEventParams.getValueAsBool('reservation_deleted');
        lireservationEntryNumber := ptrecEventParams.getValueAsInt('reservation_entry_number');

        // Get the parent line.
        lrecVICConsumptionBatchLine.Get(lcodFacilityID, lcodBatchNumber, liLineIdNumber);

        if lbreservation_deleted then begin
            if lrecVICBatchTransaction.get(lireservationEntryNumber) then begin
                lrecVICBatchTransaction.Delete();
            end
        end
        else if lbreservation_modified then begin
            if lrecVICBatchTransaction.get(lireservationEntryNumber) then begin
                lrecVICBatchTransaction.Quantity := ldQtyToComplete;
                lrecVICBatchTransaction.LotNumber := lcodLotNumber;
                lrecVICBatchTransaction.LotExpirationDate := ldtExpirationDate;
                lrecVICBatchTransaction.Modify();
            end
        end
        else if lbreservation_added then begin
            lrecVICBatchTransaction.Init();
            lrecVICBatchTransaction.User := lcodUser;
            lrecVICBatchTransaction.FacilityId := lcodFacilityID;
            lrecVICBatchTransaction.BatchNumber := lcodBatchNumber;
            lrecVICBatchTransaction.LineIdNumber := liLineIdNumber;
            lrecVICBatchTransaction.ComponentId := lrecVICConsumptionBatchLine.ComponentId;
            lrecVICBatchTransaction.LotNumber := lcodLotNumber;
            lrecVICBatchTransaction.LotExpirationDate := ldtExpirationDate;
            lrecVICBatchTransaction.Quantity := ldQtyToComplete;
            lrecVICBatchTransaction.ConsumptionTransaction := false;
            lrecVICBatchTransaction.Insert();
        end;

        lrecVICBatchTransaction.Reset();
        lrecVICBatchTransaction.SetRange(User, lcodUser);
        lrecVICBatchTransaction.SetRange(FacilityId, lcodFacilityID);
        lrecVICBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
        lrecVICBatchTransaction.SetRange(LineIdNumber, liLineIdNumber);

        ldTotalQuantityToPost := 0;
        if lrecVICBatchTransaction.FindSet(false) then
            repeat
                ldTotalQuantityToPost += lrecVICBatchTransaction.Quantity;
            until (lrecVICBatchTransaction.Next() = 0);

        // Update the parent line. 
        ldPreviousQuantity := lrecVICConsumptionBatchLine.QuantityToComplete;
        lrecVICConsumptionBatchLine.QuantityToComplete := ldTotalQuantityToPost; // ldPreviousQuantity + ldQtyToComplete;
        lrecVICConsumptionBatchLine.QuantityRemaining := lrecVICConsumptionBatchLine.QuantityOrdered - lrecVICConsumptionBatchLine.QuantityCompleted - lrecVICConsumptionBatchLine.QuantityUnposted - ldTotalQuantityToPost; // lrecVICOutoutBatchLine.QuantityRemaining - ldQtyToComplete;
        lrecVICConsumptionBatchLine.LotNumber := lcodLotNumber;
        lrecVICConsumptionBatchLine.ExpirationDate := ldtExpirationDate;
        lrecVICConsumptionBatchLine.Modify(true);

        // Error('Total quantity to post: ' + Format(ldTotalQuantityToPost));

        lrecVICConsumptionBatchLine.SetRecFilter();

        lrrefLineRef.GetTable(lrecVICConsumptionBatchLine);

        ldnOutput.Append('<DATASET>');

        //        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', iEventID, DATABASE::"VIC IW Batch Output"));
        ldnOutput.Append(StrSubstNo('<TABLE id="line" eventid="%1" tableid="%2">', 2500011, DATABASE::"VIC IW Batch Consumption"));

        //
        // "line" columns
        //
        ldnOutput.Append('<COLS>');
        cuCommonFuncs.initializeColumns(true);

        // Grab the column defintions as defined in the device configuration
        // Change table to match your needs
        //        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, iEventID, '', DATABASE::"VIC IW Batch Output");
        cuCommonFuncs.addDSColumnsFromConfigDN(ldnOutput, 2500011, '', DATABASE::"VIC IW Batch Consumption");
        cuCommonFuncs.addDSTrackingColumnsDN(ldnOutput);
        ldnOutput.Append('</COLS>');


        //
        // "line" rows
        //


        ldnOutput.Append('<ROWS>'); // start "line" rows

        lrecVICConsumptionBatchLine.SetRange(FacilityId, lcodFacilityID);
        lrecVICConsumptionBatchLine.SetRange(BatchNumber, lcodBatchNumber);

        // loop through the lines and build up each row
        if (lrecVICConsumptionBatchLine.FindSet(false)) then
            repeat
                ldnOutput.Append('<R>');  // start "line" row

                //
                // "line" fields
                //
                ldnOutput.Append('<FIELDS>');

                // you might have some existing code similar to this alredy - just move/replace this with that
                // change table to match
                cuCommonFuncs.setDSFieldOverrideValue(iEventID,
                '',
                DATABASE::"VIC IW Batch Output",
                lrecVICConsumptionBatchLine.FieldNo("QuantityRemaining"),
                StrSubstNo('%1', (lrecVICConsumptionBatchLine.QuantityOrdered - lrecVICConsumptionBatchLine.QuantityCompleted - lrecVICConsumptionBatchLine.QuantityToComplete)));
                lrrefLineRef.GetTable(lrecVICConsumptionBatchLine);
                //                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefLineRef, iEventID, '');
                cuCommonFuncs.addDSFieldsForRecordDN(ldnOutput, lrrefLineRef, 2500001, '');

                // add this so it knows what the item tracking code/values are for the line
                lrecItem.Get(lrecVICConsumptionBatchLine.ComponentId);
                cuCommonFuncs.addDSTrackingFieldsDN(ldnOutput, lrecItem."Item Tracking Code");
                ldnOutput.Append('</FIELDS>');


                //
                // "line" item tracking entries
                //
                lrecVICBatchTransaction.SetRange(FacilityId, lcodFacilityID);
                lrecVICBatchTransaction.SetRange(BatchNumber, lcodBatchNumber);
                lrecVICBatchTransaction.SetRange(LineIdNumber, lrecVICConsumptionBatchLine.LineIdNumber);
                if lrecVICBatchTransaction.FindSet(false) then
                    repeat
                        // ensure these fields are all returned/added
                        // I've left them as mapped up to the standard reservatione entry table but if they don't apply to your scenario,
                        //   then maybe default to "0" for integers and "" for text
                        ldnOutput.Append('<LINE>');
                        ldnOutput.Append(StrSubstNo('<ENTRY_NUMBER>%1</ENTRY_NUMBER>', lrecVICBatchTransaction."Line No."));
                        ldnOutput.Append(StrSubstNo('<ITEM_NUMBER>%1</ITEM_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.ComponentId)));
                        ldnOutput.Append(StrSubstNo('<SERIAL_NUMBER>%1</SERIAL_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<SOURCE_ID>%1</SOURCE_ID>', lrecVICBatchTransaction.BatchNumber));
                        ldnOutput.Append(StrSubstNo('<SOURCE_REF_NUMBER>%1</SOURCE_REF_NUMBER>', 0));
                        ldnOutput.Append(StrSubstNo('<POSITIVE>%1</POSITIVE>', true));
                        ldnOutput.Append(StrSubstNo('<QTY_BASE>%1</QTY_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<LOT_NUMBER>%1</LOT_NUMBER>', cuCommonFuncs.escapeText(lrecVICBatchTransaction.LotNumber)));
                        ldnOutput.Append(StrSubstNo('<PACKAGE_NUMBER>%1</PACKAGE_NUMBER>', cuCommonFuncs.escapeText('')));
                        ldnOutput.Append(StrSubstNo('<QTY_HANDLE_BASE>%1</QTY_HANDLE_BASE>', lrecVICBatchTransaction.Quantity));
                        ldnOutput.Append(StrSubstNo('<QTY_PER_UOM>%1</QTY_PER_UOM>', 1));
                        ldnOutput.Append(StrSubstNo('<ITEM_TRACKING>%1</ITEM_TRACKING>', lrecVICBatchTransaction."Item Tracking".AsInteger()));
                        ldnOutput.Append(StrSubstNo('<EXP>%1</EXP>', lrecVICBatchTransaction.LotExpirationDate));
                        ldnOutput.Append('</LINE>');
                    until (lrecVICBatchTransaction.Next() = 0);

                ldnOutput.Append('</R>');  // end "line" row

            until (lrecVICConsumptionBatchLine.Next() = 0);


        ldnOutput.Append('</ROWS>');    // end "line" rows
        ldnOutput.Append('</TABLE>');   // end "line" table
        ldnOutput.Append('</DATASET>');

        pbsOutput.AddText(ldnOutput.ToText());

        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch Output"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        ptrecEventParams.setValue('Previous Quantity', Format(ldPreviousQuantity));
        ptrecEventParams.setValue('New Quantity', Format(ldQtyToComplete));
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure PostVICOutputBatch(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICOutputBatch: Record "VIC IW Batch";
        lrecVICOutoutBatchLine: Record "VIC IW Batch Output";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodUser: Code[50];
        ltcLogDetailsMsg: Label 'Post Batch [%1]', Comment = '%1=Batch Number';
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
        lsResultMessage: Text;
    begin
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('output_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lsResultMessage := '';


        lrecVICOutputBatch.Get(lcodUser, lcodFacilityID, lcodBatchNumber);

        lcuVICWebServiceInterface.OnPostIWBatchOutput(lcodFacilityID, lcodBatchNumber, lcodUser, System.Today, lsResultMessage);

        lrecVICOutoutBatchLine.SetRange(FacilityId, lcodFacilityID);
        lrecVICOutoutBatchLine.SetRange(BatchNumber, lcodBatchNumber);

        //
        // do posting here
        //


        // loop through the lines and build up each row
        if (lrecVICOutoutBatchLine.FindSet(false)) then
            repeat
            // process each line
            until lrecVICOutoutBatchLine.Next() = 0;


        this.cuCommonFuncs.generateSuccessReturn(lsResultMessage, pbsOutput);



        ptrecEventParams.setValue('details', StrSubstNo(ltcLogDetailsMsg, lcodBatchNumber));
        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    procedure PostVICConsumptionBatch(var ptrecEventParams: Record "IWX Event Param" temporary; var pbsOutput: BigText)
    var
        lrecVICInputBatch: Record "VIC IW Batch";
        lrecVICInputBatchLine: Record "VIC IW Batch Consumption";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lcodFacilityID: Code[15];
        lcodBatchNumber: Code[20];
        lcodUser: Code[50];
        ltcLogDetailsMsg: Label 'Post Batch [%1]', Comment = '%1=Batch Number';
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
        lsResultMessage: Text;
    begin
        lcodFacilityID := CopyStr(ptrecEventParams.GetExtendedValue('facility_id'), 1, MaxStrLen(lcodFacilityID));
        lcodBatchNumber := CopyStr(ptrecEventParams.GetExtendedValue('input_batch_number'), 1, MaxStrLen(lcodBatchNumber));
        lcodUser := CopyStr(ptrecEventParams.GetExtendedValue('user_name'), 1, MaxStrLen(lcodUser));
        lsResultMessage := '';


        lrecVICInputBatch.Get(lcodUser, lcodFacilityID, lcodBatchNumber);

        // Post to the batch.
        lcuVICWebServiceInterface.OnPostIWBatchInput(lcodFacilityID, lcodBatchNumber, lcodUser, System.Today, lsResultMessage);

        lrecVICInputBatchLine.SetRange(FacilityId, lcodFacilityID);
        lrecVICInputBatchLine.SetRange(BatchNumber, lcodBatchNumber);

        //
        // do posting here
        //


        // loop through the lines and build up each row
        if (lrecVICInputBatchLine.FindSet(false)) then
            repeat
            // process each line
            until lrecVICInputBatchLine.Next() = 0;


        this.cuCommonFuncs.generateSuccessReturn(lsResultMessage, pbsOutput);



        ptrecEventParams.setValue('details', StrSubstNo(ltcLogDetailsMsg, lcodBatchNumber));
        ptrecEventParams.setValue('Document Type', Format(DATABASE::"VIC IW Batch"));
        ptrecEventParams.setValue('Document No.', lcodBatchNumber);
        this.cuActivityLogMgt.logActivity(ptrecEventParams);
    end;

    local procedure UpdateVICBatches(pcodUser: Code[50])
    var
        lrecVICSetup: Record "Vicinity Setup";
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
    begin
        if not lrecVICSetup.Get() then
            Error(tcSetupNotCompletedErr);
        if StrLen(lrecVICSetup.ApiUrl) = 0 then
            Error(tcAPINotCompletedErr);

        // Populate "VIC IW Batch" from Vicinity web services.
        lcuVICWebServiceInterface.OnFetchIWBatch(pcodUser);
    end;

    local procedure UpdateVicBatchOutputs(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    var
        lrecVICSetup: Record "Vicinity Setup";
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
    begin
        if not lrecVICSetup.Get() then
            Error(tcSetupNotCompletedErr);

        if StrLen(lrecVICSetup.ApiUrl) = 0 then
            Error(tcAPINotCompletedErr);

        lcuVICWebServiceInterface.OnFetchIWBatchOutput(psFacilityId, psBatchNumber, pcodUser);
    end;

    local procedure UpdateVicBatchInputs(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    var
        lrecVICSetup: Record "Vicinity Setup";
        // lrecVICConnectorSetup: Record "VIC Connector Setup";
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
    begin
        if not lrecVICSetup.Get() then
            Error(tcSetupNotCompletedErr);

        if StrLen(lrecVICSetup.ApiUrl) = 0 then
            Error(tcAPINotCompletedErr);

        lcuVICWebServiceInterface.OnFetchIWBatchConsumption(psFacilityId, psBatchNumber, pcodUser);
    end;

    local procedure EscapeFilterString(psFilter: Text): Text
    var
        lsEscapedFilter: Text;
    begin
        if psFilter = '' then
            exit('');

        lsEscapedFilter := '*' + psFilter + '*';

        if lsEscapedFilter.Contains('&') or lsEscapedFilter.Contains('(') or lsEscapedFilter.Contains(')') or
            lsEscapedFilter.Contains('|') or lsEscapedFilter.Contains('=') then
            lsEscapedFilter := '''' + lsEscapedFilter + '''';

        exit(lsEscapedFilter);
    end;

    var
        cuDataSetTools: Codeunit "WHI Dataset Tools";
        cuActivityLogMgt: Codeunit "WHI Activity Log Mgmt.";
        cuCommonFuncs: Codeunit "WHI Common Functions";
        iEventID: Integer;
        tcSetupNotCompletedErr: Label 'Vicinity Setup record does not exist.';
        tcAPINotCompletedErr: Label 'Vicinity API URL has not been configured on the Vicinity Setup page.';
}