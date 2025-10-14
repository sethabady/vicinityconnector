codeunit 50803 "VIC Web Api"
{
    [IntegrationEvent(false, false)]
    procedure OnFetchIWBatch(pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFetchIWBatchConsumption(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFetchIWBatchOutput(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostIWBatchOutput(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50]; pdtPostDate: Date; var psResultMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostIWBatchInput(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50]; pdtPostDate: Date; var psResultMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostBatchEndItems(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostBatchConsumptions(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchIWBatch', '', false, false)]
    local procedure OnFetchIWBatchSubscriber(pcodUser: Code[50])
    var
        lsUrl: Text;
        lsVicinityApiUrl: Text;
        lsVicinityCompanyId: Text;
        lsVicinityUserId: Text;
        lsVicinityApiAccessKey: Text;
        lrecVicinitySetup: Record "Vicinity Setup";
        lrecIWBatch: Record "VIC IW Batch";
        lrecIWBatchOutput: Record "VIC IW Batch Output";
        lrecIWBatchConsumption: Record "VIC IW Batch Consumption";
        lrecIWBatchTransaction: Record "VIC IW Batch Transaction";
        lrecIWBatchLotNumber: Record "VIC IW Batch Lot Number";

        lhcClient: HttpClient;
        lhrRequest: HttpRequestMessage;
        lhrspResponse: HttpResponseMessage;
        lsResponseString: Text;
        ljtResponseString: JsonToken;
        ljtBatch: JsonToken;
    begin
        lrecIWBatch.Reset();
        lrecIWBatch.SetRange(User, pcodUser);
        lrecIWBatch.DeleteAll();

        lrecIWBatchOutput.Reset();
        lrecIWBatchOutput.SetRange(User, pcodUser);
        lrecIWBatchOutput.DeleteAll();

        lrecIWBatchConsumption.Reset();
        lrecIWBatchConsumption.SetRange(User, pcodUser);
        lrecIWBatchConsumption.DeleteAll();

        lrecIWBatchTransaction.Reset();
        lrecIWBatchTransaction.SetRange(User, pcodUser);
        lrecIWBatchTransaction.DeleteAll();

        lrecIWBatchLotNumber.Reset();
        lrecIWBatchLotNumber.SetRange(User, pcodUser);
        lrecIWBatchLotNumber.DeleteAll();

        lrecIWBatch.SetCurrentKey(FacilityId, BatchNumber);
        lrecVicinitySetup.Get();
        lsVicinityApiUrl := lrecVicinitySetup.ApiUrl;
        lsVicinityCompanyId := lrecVicinitySetup.CompanyId;
        lsVicinityUserId := lrecVicinitySetup.ApiUserName;
        if (StrLen(lsVicinityUserId) = 0) then begin
            lsVicinityUserId := UserId;
        end;

        lsUrl := StrSubstNo('%1/batch/%2/list', lsVicinityApiUrl, lsVicinityCompanyId);
        lhrRequest.Method := 'GET';
        lhrRequest.SetRequestUri(lsUrl); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
        if not lhcClient.Send(lhrRequest, lhrspResponse) then
            Error('OnFetchBatchSummariesSubscriber Client.Send error:\\' + GetLastErrorText);
        lhrspResponse.Content.ReadAs(lsResponseString);
        ljtResponseString.ReadFrom(lsResponseString);
        foreach ljtBatch in ljtResponseString.AsArray()
        do begin
            lrecIWBatch.Init();
            lrecIWBatch.FacilityId := GetJsonToken(ljtBatch.AsObject(), 'FacilityId').AsValue().AsText();
            lrecIWBatch.BatchNumber := GetJsonToken(ljtBatch.AsObject(), 'BatchNumber').AsValue().AsText();
            lrecIWBatch.BatchDescription := GetJsonToken(ljtBatch.AsObject(), 'Description').AsValue().AsText();
            lrecIWBatch.FormulaId := GetJsonToken(ljtBatch.AsObject(), 'FormulaId').AsValue().AsText();
            SetDateFromJson(ljtBatch, 'PlanStartDate', lrecIWBatch.PlanStartDate);
            SetDateFromJson(ljtBatch, 'PlanEndDate', lrecIWBatch.PlanEndDate);
            SetDateFromJson(ljtBatch, 'ActualStartDate', lrecIWBatch.ActualStartDate);
            SetDateFromJson(ljtBatch, 'ActualEndDate', lrecIWBatch.ActualEndDate);
            lrecIWBatch.ProcessingStage := "VIC Batch Processing Stage"::Released;
            lrecIWBatch.Status := "VIC Batch Status"::Active;
            lrecIWBatch.PostThruToBC := true;
            lrecIWBatch.Barcode := '%P%' + lrecIWBatch.BatchNumber + '|||' + lrecIWBatch.FacilityId + ' 00001';
            lrecIWBatch.User := pcodUser;
            lrecIWBatch.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchIWBatchOutput', '', false, false)]
    local procedure OnFetchIWBatchOutputSubscriber(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    var
        lsUrl: Text;
        lsVicinityApiUrl: Text;
        lsVicinityCompanyId: Text;
        lsVicinityUserId: Text;
        lsVicinityApiAccessKey: Text;
        lrecVicinitySetup: Record "Vicinity Setup";
        lrecIWBatchOutput: Record "VIC IW Batch Output";
        lrecIWBatchTransaction: Record "VIC IW Batch Transaction";
        lrecIWBatchLotNumber: Record "VIC IW Batch Lot Number";

        lhcClient: HttpClient;
        lhrRequest: HttpRequestMessage;
        lhrspResponse: HttpResponseMessage;
        lsResponseString: Text;
        ljtResponseString: JsonToken;
        ljtBatchEndItems: JsonToken;
        ljtBatchEndItem: JsonToken;
        ljaBatchEndItems: JsonArray;
        ljtBatchLotNumbers: JsonToken;
        ljtBatchLotNumber: JsonToken;
        ljaBatchLotNumbers: JsonArray;
        lrecItem: Record Item;
        ldQuantityCompleted: Decimal;
        ldQuantityToComplete: Decimal;
        ldQuantityOrdered: Decimal;
        ldQuantityRemaining: Decimal;
    begin
        lrecIWBatchOutput.Reset();
        lrecIWBatchOutput.SetRange(User, pcodUser);
        lrecIWBatchOutput.DeleteAll();
        lrecIWBatchOutput.SetCurrentKey(FacilityId, BatchNumber, User);

        lrecIWBatchTransaction.Reset();
        lrecIWBatchTransaction.SetRange(User, pcodUser);
        lrecIWBatchTransaction.DeleteAll();

        lrecIWBatchLotNumber.Reset();
        lrecIWBatchLotNumber.SetRange(User, pcodUser);
        lrecIWBatchLotNumber.DeleteAll();


        lrecVicinitySetup.Get();
        lsVicinityApiUrl := lrecVicinitySetup.ApiUrl;
        lsVicinityCompanyId := lrecVicinitySetup.CompanyId;
        lsVicinityUserId := lrecVicinitySetup.ApiUserName;
        if (StrLen(lsVicinityUserId) = 0) then begin
            lsVicinityUserId := UserId;
        end;

        lsUrl := StrSubstNo('%1/batch/%2/%3/%4/enditems/withlots', lsVicinityApiUrl, lsVicinityCompanyId, psFacilityId, psBatchNumber);
        lhrRequest.Method := 'GET';
        lhrRequest.SetRequestUri(lsUrl); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/BATCH_NUMBER/enditems/withlots');
        if not lhcClient.Send(lhrRequest, lhrspResponse) then
            Error('OnFetchIWBatchOutputSubscriber Client.Send error:\\' + GetLastErrorText);

        lhrspResponse.Content.ReadAs(lsResponseString);
        ljtResponseString.ReadFrom(lsResponseString);
        if not ljtResponseString.SelectToken('[' + '''' + 'VicinityBatchEndItems' + '''' + ']', ljtBatchEndItems) then
            Error('OnFetchIWBatchOutputSubscriber:\\ SelectToken VicinityBatchEndItems failed');

        ljaBatchEndItems := ljtBatchEndItems.AsArray();
        foreach ljtBatchEndItem in ljaBatchEndItems
        do begin
            lrecIWBatchOutput.Init();
            lrecIWBatchOutput.FacilityId := GetJsonToken(ljtBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
            lrecIWBatchOutput.BatchNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
            lrecIWBatchOutput.ScanType := "VIC Batch Scan Type"::EndItem;
            lrecIWBatchOutput.ComponentId := GetJsonToken(ljtBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText();
            lrecIWBatchOutput.LocationCode := GetJsonToken(ljtBatchEndItem.AsObject(), 'SiteId').AsValue().AsText();
            lrecIWBatchOutput.LineIdNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();

            // Vicinity quantity ordered.
            ldQuantityOrdered := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyCurrentInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityOrdered := ldQuantityOrdered;

            // Vicnity quantity completed and posted.
            ldQuantityCompleted := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyCompleteInDisplayUOM').AsValue().AsDecimal() + GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyToCompleteInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityCompleted := ldQuantityCompleted;
    
            // Vicinity quantity to complete but not yet posted.
            ldQuantityToComplete := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyToCompleteInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityUnposted := ldQuantityToComplete;

            // Vicinity quantity remaining is original quantity less quantity posted as well as unposted.
            ldQuantityRemaining := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityRemaining := ldQuantityRemaining;

            lrecIWBatchOutput.UnitOfMeasure := GetJsonToken(ljtBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
            lrecIWBatchOutput.LotNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
            if lrecItem.Get(lrecIWBatchOutput.ComponentId) then
                lrecIWBatchOutput.Description := lrecItem.Description
            else
                lrecIWBatchOutput.Description := 'NOT FOUND';
            lrecIWBatchOutput.BinCode := GetJsonToken(ljtBatchEndItem.AsObject(), 'BinNumber').AsValue().AsText();
            lrecIWBatchOutput.User := pcodUser;
            lrecIWBatchOutput.Insert();

            if not ljtBatchEndItem.SelectToken('[' + '''' + 'AssignableLotNumbers' + '''' + ']', ljtBatchLotNumbers) then
                Error('OnFetchIWBatchOutputSubscriber:\\ SelectToken AssignableLotNumbers failed');
            foreach ljtBatchLotNumber in ljtBatchLotNumbers.AsArray() do begin
                lrecIWBatchLotNumber.Init();
                lrecIWBatchLotNumber.User := pcodUser;
                lrecIWBatchLotNumber.FacilityId := GetJsonToken(ljtBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
                lrecIWBatchLotNumber.BatchNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
                lrecIWBatchLotNumber.LineIdNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();
                lrecIWBatchLotNumber.SequenceNumber := GetJsonToken(ljtBatchLotNumber.AsObject(), 'SequenceNumber').AsValue().AsInteger();
                lrecIWBatchLotNumber.LotNumber := GetJsonToken(ljtBatchLotNumber.AsObject(), 'LotNumber').AsValue().AsText();
                lrecIWBatchLotNumber.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchIWBatchConsumption', '', false, false)]
    local procedure OnFetchIWBatchConsumptionSubscriber(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50])
    var
        lsUrl: Text;
        lsVicinityApiUrl: Text;
        lsVicinityCompanyId: Text;
        lsVicinityUserId: Text;
        lsVicinityApiAccessKey: Text;
        lrecVicinitySetup: Record "Vicinity Setup";
        lrecIWBatchConsumption: Record "VIC IW Batch Consumption";

        lhcClient: HttpClient;
        lhrRequest: HttpRequestMessage;
        lhrspResponse: HttpResponseMessage;
        lsResponseString: Text;
        ljtResponseString: JsonToken;
        ljtBatchProcedures: JsonToken;
        ljtBatchProcedure: JsonToken;
        ljaBatchProcedures: JsonArray;
        lrecItem: Record Item;
    begin
        lrecIWBatchConsumption.Reset();
        lrecIWBatchConsumption.DeleteAll();
        lrecIWBatchConsumption.SetCurrentKey(FacilityId, BatchNumber, User);
        lrecVicinitySetup.Get();
        lsVicinityApiUrl := lrecVicinitySetup.ApiUrl;
        lsVicinityCompanyId := lrecVicinitySetup.CompanyId;
        lsVicinityUserId := lrecVicinitySetup.ApiUserName;
        if (StrLen(lsVicinityUserId) = 0) then begin
            lsVicinityUserId := UserId;
        end;

        // Get batch procedures.
        lsUrl := StrSubstNo('%1/batch/%2/%3/%4/procedures', lsVicinityApiUrl, lsVicinityCompanyId, psFacilityId, psBatchNumber);

        lhrRequest.Method := 'GET';
        lhrRequest.SetRequestUri(lsUrl); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/BATCH_NUMBER/procedures');
        if not lhcClient.Send(lhrRequest, lhrspResponse) then
            Error('OnFetchIWBatchConsumptionSubscriber Client.Send error:\\' + GetLastErrorText);

        // Response.Content.ReadAs(ResponseString);
        lhrspResponse.Content.ReadAs(lsResponseString);

        // JsonTokenResponseString.ReadFrom(ResponseString);
        ljtResponseString.ReadFrom(lsResponseString);

        // JsonArrayBatchProcedures := JsonTokenResponseString.AsArray();
        ljaBatchProcedures := ljtResponseString.AsArray();

        foreach ljtBatchProcedure in ljaBatchProcedures
        do begin
            if (GetJsonToken(ljtBatchProcedure.AsObject(), 'ComponentId').AsValue().AsText() <> '') then begin
                lrecIWBatchConsumption.Init();
                lrecIWBatchConsumption.FacilityId := GetJsonToken(ljtBatchProcedure.AsObject(), 'FacilityId').AsValue().AsText();
                lrecIWBatchConsumption.BatchNumber := GetJsonToken(ljtBatchProcedure.AsObject(), 'BatchNumber').AsValue().AsText();
                lrecIWBatchConsumption.ScanType := "VIC Batch Scan Type"::Ingredient;
                lrecIWBatchConsumption.ComponentId := GetJsonToken(ljtBatchProcedure.AsObject(), 'ComponentId').AsValue().AsText();
                lrecIWBatchConsumption.LocationCode := GetJsonToken(ljtBatchProcedure.AsObject(), 'SiteId').AsValue().AsText();
                lrecIWBatchConsumption.LineIdNumber := GetJsonToken(ljtBatchProcedure.AsObject(), 'LineIdNumber').AsValue().AsInteger();
                lrecIWBatchConsumption.QuantityOrdered := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyRequiredInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityRemaining := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityCompleted := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityUnposted := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyToIssueInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.UnitOfMeasure := GetJsonToken(ljtBatchProcedure.AsObject(), 'UnitId').AsValue().AsText();
                lrecIWBatchConsumption.LotNumber := ''; //GetJsonToken(ljtBatchProcedure.AsObject(), 'LotNumber').AsValue().AsText();
                if lrecItem.Get(lrecIWBatchConsumption.ComponentId) then
                    lrecIWBatchConsumption.Description := lrecItem.Description
                else
                    lrecIWBatchConsumption.Description := 'NOT FOUND';
                lrecIWBatchConsumption.BinCode := GetJsonToken(ljtBatchProcedure.AsObject(), 'BinNumber').AsValue().AsText();
                lrecIWBatchConsumption.User := pcodUser;
                lrecIWBatchConsumption.Insert();
            end;
        end;

        // Get batch end-item BOM.
        lsUrl := StrSubstNo('%1/batch/%2/%3/%4/bom', lsVicinityApiUrl, lsVicinityCompanyId, psFacilityId, psBatchNumber);
        System.Clear(lhcClient);
        System.Clear(lhrRequest);
        lhrRequest.Method := 'GET';
        lhrRequest.SetRequestUri(lsUrl); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/BATCH_NUMBER/bom');
        if not lhcClient.Send(lhrRequest, lhrspResponse) then
            Error('OnFetchIWBatchConsumptionSubscriber Client.Send error:\\' + GetLastErrorText);

        // Response.Content.ReadAs(ResponseString);
        lhrspResponse.Content.ReadAs(lsResponseString);

        // JsonTokenResponseString.ReadFrom(ResponseString);
        ljtResponseString.ReadFrom(lsResponseString);

        // JsonArrayBatchProcedures := JsonTokenResponseString.AsArray();
        ljaBatchProcedures := ljtResponseString.AsArray();
        foreach ljtBatchProcedure in ljaBatchProcedures
        do begin
            if (GetJsonToken(ljtBatchProcedure.AsObject(), 'SubComponentId').AsValue().AsText() <> '') then begin
                lrecIWBatchConsumption.Init();
                lrecIWBatchConsumption.FacilityId := GetJsonToken(ljtBatchProcedure.AsObject(), 'FacilityId').AsValue().AsText();
                lrecIWBatchConsumption.BatchNumber := GetJsonToken(ljtBatchProcedure.AsObject(), 'BatchNumber').AsValue().AsText();
                lrecIWBatchConsumption.ScanType := "VIC Batch Scan Type"::Ingredient;
                lrecIWBatchConsumption.ParentComponentId := GetJsonToken(ljtBatchProcedure.AsObject(), 'ComponentId').AsValue().AsText();
                lrecIWBatchConsumption.ComponentId := GetJsonToken(ljtBatchProcedure.AsObject(), 'SubComponentId').AsValue().AsText();
                lrecIWBatchConsumption.LocationCode := GetJsonToken(ljtBatchProcedure.AsObject(), 'SiteId').AsValue().AsText();
                lrecIWBatchConsumption.LineIdNumber := GetJsonToken(ljtBatchProcedure.AsObject(), 'LineIdNumber').AsValue().AsInteger();
                lrecIWBatchConsumption.QuantityOrdered := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyRequiredInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityRemaining := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityCompleted := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.QuantityUnposted := GetJsonToken(ljtBatchProcedure.AsObject(), 'QtyToIssueInDisplayUOM').AsValue().AsDecimal();
                lrecIWBatchConsumption.UnitOfMeasure := GetJsonToken(ljtBatchProcedure.AsObject(), 'UnitId').AsValue().AsText();
                lrecIWBatchConsumption.LotNumber := ''; //GetJsonToken(ljtBatchProcedure.AsObject(), 'LotNumber').AsValue().AsText();
                if lrecItem.Get(lrecIWBatchConsumption.ComponentId) then
                    lrecIWBatchConsumption.Description := lrecItem.Description
                else
                    lrecIWBatchConsumption.Description := 'NOT FOUND';
                lrecIWBatchConsumption.BinCode := GetJsonToken(ljtBatchProcedure.AsObject(), 'BinNumber').AsValue().AsText();
                lrecIWBatchConsumption.User := pcodUser;
                lrecIWBatchConsumption.Insert();
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnPostIWBatchOutput', '', false, false)]
    local procedure OnPostIWBatchOutputSubscriber(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50]; pdtPostDate: Date; var psResultMessage: Text)
    var
        lrecVICBatchOutput: Record "VIC IW Batch Output";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lrecWHISetup: Record "WHI Setup";
        lboolPostThruToBC: Boolean;
        ljsonTempValue: JsonValue;
        ljsonRequestObject: JsonObject;
        ljsonArrayBatchTransactions: JsonArray;
        lbIsHandled: Boolean;
        lsResultMessage: Text;
    begin
        psResultMessage := 'NOT POSTED';
        lrecVICBatchOutput.SetCurrentKey(FacilityId, BatchNumber, User);
        lrecVICBatchOutput.SetRange(FacilityId, psFacilityId);
        lrecVICBatchOutput.SetRange(BatchNumber, psBatchNumber);
        lrecVICBatchOutput.SetRange(User, pcodUser);

        if lrecWHISetup.Get() then
            lboolPostThruToBC := lrecWHISetup.PostToBC
        else
            lboolPostThruToBC := false;

        if lrecVICBatchOutput.FindFirst() then begin
            psResultMessage := '';
            
            ljsonTempValue.SetValue(pdtPostDate);

            ljsonRequestObject.Add('TransactionDate', ljsonTempValue);
            ljsonRequestObject.Add('UserID', pcodUser);
            ljsonRequestObject.Add('BatchNumber', psBatchNumber);
            ljsonRequestObject.Add('FacilityId', psFacilityId);
            if lboolPostThruToBC then
                ljsonRequestObject.Add('GPBatchNumber', 'CBOTTSOP')  // POSTTOBC backwards (for now)
            else
                ljsonRequestObject.Add('GPBatchNumber', '');

            repeat
                lrecVICBatchTransaction.SetCurrentKey(User, FacilityId, BatchNumber, LineIdNumber);
                lrecVICBatchTransaction.SetRange(User, pcodUser);
                lrecVICBatchTransaction.SetRange(FacilityId, psFacilityId);
                lrecVICBatchTransaction.SetRange(BatchNumber, psBatchNumber);
                lrecVICBatchTransaction.SetRange(LineIdNumber, lrecVICBatchOutput.LineIdNumber);
                if lrecVICBatchTransaction.FindFirst() then begin
                    repeat
                        AddTransactionToJson(lrecVICBatchOutput, lrecVICBatchTransaction, ljsonArrayBatchTransactions);
                    until lrecVICBatchTransaction.Next() = 0;
                end
            until lrecVICBatchOutput.Next() = 0;

            // Add populated transaction array to request object.
            ljsonRequestObject.Add('BatchTransactions', ljsonArrayBatchTransactions);
            OnPostBatchEndItems(ljsonRequestObject, lbIsHandled, lsResultMessage);
            if lbIsHandled then begin
                psResultMessage := 'Batch ' + lrecVICBatchOutput.BatchNumber + ' posted successfully.';
            end
            else
                psResultMessage := 'OnPostIWBatchOutput error: ' + lsResultMessage;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnPostIWBatchInput', '', false, false)]
    local procedure OnPostIWBatchInputSubscriber(psFacilityId: Text; psBatchNumber: Text; pcodUser: Code[50]; pdtPostDate: Date; var psResultMessage: Text)
    var
        lrecVICBatchInput: Record "VIC IW Batch Consumption";
        lrecVICBatchTransaction: Record "VIC IW Batch Transaction";
        lboolPostThruToBC: Boolean;
        ljsonTempValue: JsonValue;
        ljsonRequestObject: JsonObject;
        ljsonArrayBatchTransactions: JsonArray;
        lbIsHandled: Boolean;
        lsResultMessage: Text;
        lsTemp: Text;
    begin
        psResultMessage := 'NOT POSTED';
        lrecVICBatchInput.SetCurrentKey(FacilityId, BatchNumber, User);
        lrecVICBatchInput.SetRange(FacilityId, psFacilityId);
        lrecVICBatchInput.SetRange(BatchNumber, psBatchNumber);
        lrecVICBatchInput.SetRange(User, pcodUser);

        lboolPostThruToBC := false;

        if lrecVICBatchInput.FindFirst() then begin
            psResultMessage := '';


            ljsonTempValue.SetValue(pdtPostDate);

            ljsonRequestObject.Add('TransactionDate', ljsonTempValue);
            ljsonRequestObject.Add('UserID', pcodUser);
            ljsonRequestObject.Add('BatchNumber', psBatchNumber);
            ljsonRequestObject.Add('FacilityId', psFacilityId);
            if lboolPostThruToBC then
                ljsonRequestObject.Add('GPBatchNumber', 'CBOTTSOP')  // POSTTOBC backwards (for now)
            else
                ljsonRequestObject.Add('GPBatchNumber', '');

            repeat
                lrecVICBatchTransaction.SetCurrentKey(User, FacilityId, BatchNumber, LineIdNumber);
                lrecVICBatchTransaction.SetRange(User, pcodUser);
                lrecVICBatchTransaction.SetRange(FacilityId, psFacilityId);
                lrecVICBatchTransaction.SetRange(BatchNumber, psBatchNumber);
                lrecVICBatchTransaction.SetRange(LineIdNumber, lrecVICBatchInput.LineIdNumber);
                if lrecVICBatchTransaction.FindFirst() then begin
                    repeat
                        AddInputTransactionToJson(lrecVICBatchInput, lrecVICBatchTransaction, ljsonArrayBatchTransactions);
                    until lrecVICBatchTransaction.Next() = 0;
                end
            until lrecVICBatchInput.Next() = 0;

            // Add populated transaction array to request object.
            ljsonRequestObject.Add('VicinityBatchTransactions', ljsonArrayBatchTransactions);

            OnPostBatchConsumptions(ljsonRequestObject, lbIsHandled, lsResultMessage);

            if lbIsHandled then begin
                psResultMessage := 'Batch ' + lrecVICBatchInput.BatchNumber + ' posted successfully.';
            end
            else
                psResultMessage := 'OnPostIWBatchInput error: ' + lsResultMessage;
        end;
    end;

    local procedure AddInputTransactionToJson(precVICBatchOutput: Record "VIC IW Batch Consumption"; precVICBatchTransaction: Record "VIC IW Batch Transaction"; pjsonArrayBatchTransactions: JsonArray)
    var
        ljsonObjectBatchTransaction: JsonObject;
        ljsonObjectQuantity: JsonObject;
        ljsonObjectBatchLot: JsonObject;
        ljsonArrayBatchLots: JsonArray;

        lsTemp: Text;
    begin
        ljsonObjectBatchTransaction.Add('ComponentId', precVICBatchOutput.ComponentId);
        ljsonObjectBatchTransaction.Add('SiteId', precVICBatchOutput.LocationCode);
        ljsonObjectBatchTransaction.Add('BinNumber', precVICBatchOutput.BinCode);
        ljsonObjectBatchTransaction.Add('LineIdNumber', precVICBatchOutput.LineIdNumber);

        // Create and add quantity object.
        ljsonObjectQuantity.Add('DecimalDigits', 5);
        ljsonObjectQuantity.Add('Value', precVICBatchTransaction.Quantity);
        ljsonObjectBatchTransaction.Add('TransactionQuantity', ljsonObjectQuantity);

        // Create and add lot object.
        if precVICBatchTransaction.LotNumber <> '' then begin
            ljsonObjectBatchLot.Add('LotNumber', precVICBatchTransaction.LotNumber);

            // ljsonObjectBatchLot.Add('ReceiptDate', System.Today());
            // ljsonObjectBatchLot.Add('MfgDate', System.Today());
            // ljsonObjectBatchLot.Add('ExpnDate', CalcDate('<+30D>', System.Today()));
            ljsonObjectBatchLot.Add('LotQuantity', ljsonObjectQuantity);
            ljsonArrayBatchLots.Add(ljsonObjectBatchLot);
            ljsonObjectBatchTransaction.Add('TransactionLots', ljsonArrayBatchLots);
        end;

        // Add populated transaction to array of transactions.
        pjsonArrayBatchTransactions.Add(ljsonObjectBatchTransaction);

        ljsonObjectBatchTransaction.WriteTo(lsTemp);
    end;

    local procedure AddTransactionToJson(precVICBatchOutput: Record "VIC IW Batch Output"; precVICBatchTransaction: Record "VIC IW Batch Transaction"; pjsonArrayBatchTransactions: JsonArray)
    var
        ljsonObjectBatchTransaction: JsonObject;
        ljsonObjectQuantity: JsonObject;
        ljsonObjectBatchLot: JsonObject;
        ljsonArrayBatchLots: JsonArray;
    begin
        ljsonObjectBatchTransaction.Add('ComponentId', precVICBatchOutput.ComponentId);
        ljsonObjectBatchTransaction.Add('SiteId', precVICBatchOutput.LocationCode);
        ljsonObjectBatchTransaction.Add('BinNumber', precVICBatchOutput.BinCode);
        ljsonObjectBatchTransaction.Add('LineIdNumber', precVICBatchOutput.LineIdNumber);

        // Create and add quantity object.
        ljsonObjectQuantity.Add('DecimalDigits', 5);
        ljsonObjectQuantity.Add('Value', precVICBatchTransaction.Quantity);
        ljsonObjectBatchTransaction.Add('Quantity', ljsonObjectQuantity);

        // Create and add lot object.
        if precVICBatchTransaction.LotNumber <> '' then begin
            ljsonObjectBatchLot.Add('LotNumber', precVICBatchTransaction.LotNumber);
            ljsonObjectBatchLot.Add('ReceiptDate', System.Today());
            ljsonObjectBatchLot.Add('MfgDate', System.Today());
            ljsonObjectBatchLot.Add('ExpnDate', CalcDate('<+30D>', System.Today()));
            ljsonObjectBatchLot.Add('Quantity', ljsonObjectQuantity);
            ljsonArrayBatchLots.Add(ljsonObjectBatchLot);
            ljsonObjectBatchTransaction.Add('BatchLots', ljsonArrayBatchLots);
        end;

        // Add populated transaction to array of transactions.
        pjsonArrayBatchTransactions.Add(ljsonObjectBatchTransaction);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnPostBatchConsumptions', '', false, false)]
    local procedure OnPostBatchConsumptionsSubscriber(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JsonRequestData: Text;
        Headers: HttpHeaders;
        ResponseString: Text;
        JsonObjectResponseString: JsonObject;
        StatusMessage: Text;
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
    begin
        IsHandled := true;
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        Request.Method := 'POST';
        Url := StrSubstNo('%1/batch/addtransaction?companyId=%2', VicinityApiUrl, VicinityCompanyId);
        Request.SetRequestUri(Url);
        VicinityBatchToPost.WriteTo(JsonRequestData);
        Content.WriteFrom(JsonRequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then begin
            ResultMessage := 'OnPostBatchConsumptionsSubscriber Client.Send error:\\' + GetLastErrorText + '\\';
            IsHandled := false;
            exit;
        end;

        Response.Content.ReadAs(ResponseString);
        JsonObjectResponseString.ReadFrom(ResponseString);
        StatusMessage := GetJsonToken(JsonObjectResponseString, 'StatusMessage').AsValue().AsText();
        if StatusMessage <> '' then begin
            ResultMessage := 'PostTransaction web service error: ' + StatusMessage + '\\';
            IsHandled := false;
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnPostBatchEndItems', '', false, false)]
    local procedure OnPostBatchEndItemsSubscriber(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        JsonRequestData: Text;
        Headers: HttpHeaders;
        ResponseString: Text;
        JsonObjectResponseString: JsonObject;
        StatusMessage: Text;
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "Vicinity Setup";
    begin
        IsHandled := true;
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        Request.Method := 'POST';
        Url := StrSubstNo('%1/batch/posttransaction?companyId=%2', VicinityApiUrl, VicinityCompanyId);
        Request.SetRequestUri(Url);
        VicinityBatchToPost.WriteTo(JsonRequestData);
        Content.WriteFrom(JsonRequestData);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');
        Request.Content := Content;
        if not Client.Send(Request, Response) then begin
            ResultMessage := 'OnPostBatchEndItemsSubscriber Client.Send error:\\' + GetLastErrorText + '\\';
            IsHandled := false;
            exit;
        end;

        Response.Content.ReadAs(ResponseString);
        JsonObjectResponseString.ReadFrom(ResponseString);
        StatusMessage := GetJsonToken(JsonObjectResponseString, 'StatusMessage').AsValue().AsText();
        if StatusMessage <> '' then begin
            ResultMessage := 'PostTransaction web service error: ' + StatusMessage + '\\';
            IsHandled := false;
            exit;
        end;
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

    local procedure SetDateFromJson(JsonToken: JsonToken; TokenKey: Text; var DateToSet: Date)
    var
        JsonTokenDate: JsonToken;
        DateFromRecord: Text;
        DateParts: List of [Text];
    begin
        JsonTokenDate := GetJsonToken(JsonToken.AsObject(), TokenKey);
        if not JsonTokenDate.AsValue().IsNull() then begin
            DateFromRecord := GetJsonToken(JsonToken.AsObject(), TokenKey).AsValue.AsText();
            DateParts := DateFromRecord.Split('T');
            Evaluate(DateToSet, DateParts.Get(1));
        end;
    end;
}