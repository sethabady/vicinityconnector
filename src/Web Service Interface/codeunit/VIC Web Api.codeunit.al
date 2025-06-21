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
    procedure OnFetchBatchSummaries(pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFetchBatchEndItems(FacilityId: Text; BatchNumber: Text; pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnFetchBatchConsumptions(FacilityId: Text; BatchNumber: Text; pcodUser: Code[50])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnPostBatchEndItems(VicinityBatchToPost: JsonObject; var IsHandled: Boolean; var ResultMessage: Text)
    begin
    end;

    local procedure initForIW()
    var
        lrecIWBatch: Record "VIC IW Batch";
        lrecIWBatchConsumption: Record "VIC IW Batch Consumption";
        lrecIWBatchOutput: Record "VIC IW Batch Output";

        VICBatch: Record "VIC Batch To Scan";
        VICBatchOutput: Record "VIC Batch Output To Scan";
        VICBatchConsumption: Record "VIC Batch Consumption To Scan";
    begin
        lrecIWBatch.Reset();
        lrecIWBatch.DeleteAll();
        lrecIWBatch.SetCurrentKey(FacilityId, BatchNumber);
        lrecIWBatchConsumption.Reset();
        lrecIWBatchConsumption.DeleteAll();
        lrecIWBatchConsumption.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
        lrecIWBatchOutput.Reset();
        lrecIWBatchOutput.DeleteAll();
        lrecIWBatchOutput.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchIWBatch', '', false, false)]
    local procedure OnFetchIWBatchSubscriber(pcodUser: Code[50])
    var
        lsUrl: Text;
        lsVicinityApiUrl: Text;
        lsVicinityCompanyId: Text;
        lsVicinityUserId: Text;
        lsVicinityApiAccessKey: Text;
        lrecVicinitySetup: Record "VIC Connector Setup";
        lrecIWBatch: Record "VIC IW Batch";

        lhcClient: HttpClient;
        lhrRequest: HttpRequestMessage;
        lhrspResponse: HttpResponseMessage;
        lsResponseString: Text;
        ljtResponseString: JsonToken;
        ljtBatch: JsonToken;
    begin
        lrecIWBatch.Reset();
        lrecIWBatch.DeleteAll();
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
        lrecVicinitySetup: Record "VIC Connector Setup";
        lrecIWBatchOutput: Record "VIC IW Batch Output";

        lhcClient: HttpClient;
        lhrRequest: HttpRequestMessage;
        lhrspResponse: HttpResponseMessage;
        lsResponseString: Text;
        ljtResponseString: JsonToken;
        ljtBatchEndItems: JsonToken;
        ljtBatchEndItem: JsonToken;
        ljaBatchEndItems: JsonArray;
        lrecItem: Record Item;
    begin
        lrecIWBatchOutput.Reset();
        lrecIWBatchOutput.DeleteAll();
        lrecIWBatchOutput.SetCurrentKey(FacilityId, BatchNumber, User);
        lrecVicinitySetup.Get();
        lsVicinityApiUrl := lrecVicinitySetup.ApiUrl;
        lsVicinityCompanyId := lrecVicinitySetup.CompanyId;
        lsVicinityUserId := lrecVicinitySetup.ApiUserName;
        if (StrLen(lsVicinityUserId) = 0) then begin
            lsVicinityUserId := UserId;
        end;

        lsUrl := StrSubstNo('%1/batch/%2/%3/%4', lsVicinityApiUrl, lsVicinityCompanyId, psFacilityId, psBatchNumber);
        lhrRequest.Method := 'GET';
        lhrRequest.SetRequestUri(lsUrl); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/BATCH_NUMBER');
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
            lrecIWBatchOutput.QuantityOrdered := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyCurrentInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityRemaining := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityCompleted := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyCompleteInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.QuantityUnposted := GetJsonToken(ljtBatchEndItem.AsObject(), 'QtyToCompleteInDisplayUOM').AsValue().AsDecimal();
            lrecIWBatchOutput.UnitOfMeasure := GetJsonToken(ljtBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
            lrecIWBatchOutput.LotNumber := GetJsonToken(ljtBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
            if lrecItem.Get(lrecIWBatchOutput.ComponentId) then
                lrecIWBatchOutput.Description := lrecItem.Description
            else
                lrecIWBatchOutput.Description := 'NOT FOUND';
            lrecIWBatchOutput.BinCode := GetJsonToken(ljtBatchEndItem.AsObject(), 'BinNumber').AsValue().AsText();  
            lrecIWBatchOutput.User := pcodUser;
            lrecIWBatchOutput.Insert();
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
        lrecVicinitySetup: Record "VIC Connector Setup";
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
    begin
        psResultMessage := 'NOT POSTED';
        lrecVICBatchOutput.SetCurrentKey(FacilityId, BatchNumber, User);
        lrecVICBatchOutput.SetRange(FacilityId, psFacilityId);
        lrecVICBatchOutput.SetRange(BatchNumber, psBatchNumber);
        lrecVICBatchOutput.SetRange(User, pcodUser);
        if lrecVICBatchOutput.FindFirst() then begin
            psResultMessage := '';
            repeat
                psResultMessage := psResultMessage + 'Batch ' + lrecVICBatchOutput.BatchNumber + format(lrecVICBatchOutput.LineIdNumber) + 'posted\';
            until lrecVICBatchOutput.Next() = 0;
        end;
    end;

    local procedure InitBatches()
    var
        VICBatch: Record "VIC Batch To Scan";
        VICBatchOutput: Record "VIC Batch Output To Scan";
        VICBatchConsumption: Record "VIC Batch Consumption To Scan";
    begin
        VICBatch.Reset();
        VICBatch.DeleteAll();
        VICBatch.SetCurrentKey(FacilityId, BatchNumber);
        VICBatchOutput.Reset();
        VICBatchOutput.DeleteAll();
        VICBatchOutput.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
        VICBatchConsumption.Reset();
        VICBatchConsumption.DeleteAll();
        VICBatchConsumption.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchBatchSummaries', '', false, false)]
    local procedure OnFetchBatchSummariesSubscriber(pcodUser: Code[50])
    var
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "VIC Connector Setup";
        VICBatch: Record "VIC Batch To Scan";
        VICBatchEndItem: Record "VIC Batch Output To Scan";

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseString: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenBatch: JsonToken;
    begin
        InitBatches();
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;

        Url := StrSubstNo('%1/batch/%2/list', VicinityApiUrl, VicinityCompanyId);
        Request.Method := 'GET';
        Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchSummariesSubscriber Client.Send error:\\' + GetLastErrorText);
        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        foreach JsonTokenBatch in JsonTokenResponseString.AsArray()
        do begin
            VICBatch.Init();
            VICBatch.FacilityId := GetJsonToken(JsonTokenBatch.AsObject(), 'FacilityId').AsValue().AsText();
            VICBatch.BatchNumber := GetJsonToken(JsonTokenBatch.AsObject(), 'BatchNumber').AsValue().AsText();
            VICBatch.BatchDescription := GetJsonToken(JsonTokenBatch.AsObject(), 'Description').AsValue().AsText();
            VICBatch.FormulaId := GetJsonToken(JsonTokenBatch.AsObject(), 'FormulaId').AsValue().AsText();
            SetDateFromJson(JsonTokenBatch, 'PlanStartDate', VICBatch.PlanStartDate);
            SetDateFromJson(JsonTokenBatch, 'PlanEndDate', VICBatch.PlanEndDate);
            SetDateFromJson(JsonTokenBatch, 'ActualStartDate', VICBatch.ActualStartDate);
            SetDateFromJson(JsonTokenBatch, 'ActualEndDate', VICBatch.ActualEndDate);
            VICBatch.ProcessingStage := "VIC Batch Processing Stage"::Released;
            VICBatch.Status := "VIC Batch Status"::Active;
            VICBatch.PostThruToBC := true;
            VICBatch.Barcode := '%P%' + VICBatch.BatchNumber + '|||' + VICBatch.FacilityId + ' 00001';
            VICBatch.User := pcodUser;
            VICBatch.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchBatchEndItems', '', false, false)]
    local procedure OnFetchBatchEndItemsSubscriber(FacilityId: Text; BatchNumber: Text; pcodUser: Code[50])
    var
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "VIC Connector Setup";
        VICBatch: Record "VIC Batch To Scan";
        VICBatchEndItem: Record "VIC Batch Output To Scan";
        Item: Record Item;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseString: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenBatchEndItem: JsonToken;
        JsonTokenBatchEndItems: JsonToken;
        JsonArrayBatchEndItems: JsonArray;

    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        VICBatchEndItem.Reset();
        VICBatchEndItem.DeleteAll();
        VICBatchEndItem.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);


        // VicinityCompanyId := 'SA_BC';
        // VicinityApiUrl := 'http://localhost:8085/VicinityWebPublic/api/vicinityservice';
        //        Url := VicinityApiUrl + '/planning/planningtransactions?companyId=' + VicinityCompanyId + '&userId=SABADY&componentId=' + ItemNo + ' &locationId=' + LocationCode + '&includeErpData=true';

        Url := StrSubstNo('%1/batch/%2/%3/%4', VicinityApiUrl, VicinityCompanyId, FacilityId, BatchNumber);


        // RequestObject.Add('companyId', 'SA_BC');
        // RequestObject.Add('facilityId', 'CHICAGO');
        // RequestObject.WriteTo(JsonRequestData);
        // Content.WriteFrom(JsonRequestData);

        // Content.GetHeaders(Headers);
        // Headers.Clear();
        // Headers.Add('Content-Type', 'application/json');
        Request.Method := 'GET';
        Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
        // Request.Content := Content;
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchEndItemsSubscriber Client.Send error:\\' + GetLastErrorText);

        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        if not JsonTokenResponseString.SelectToken('[' + '''' + 'VicinityBatchEndItems' + '''' + ']', JsonTokenBatchEndItems) then
            Error('OnFetchBatchEndItemsSubscriber:\\ SelectToken VicinityBatchEndItems failed');

        JsonArrayBatchEndItems := JsonTokenBatchEndItems.AsArray();
        foreach JsonTokenBatchEndItem in JsonArrayBatchEndItems
        do begin
            VICBatchEndItem.Init();
            VICBatchEndItem.FacilityId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
            VICBatchEndItem.BatchNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
            VICBatchEndItem.ScanType := "VIC Batch Scan Type"::EndItem;
            VICBatchEndItem.ComponentId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText();
            VICBatchEndItem.LocationCode := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'SiteId').AsValue().AsText();
            VICBatchEndItem.LineIdNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();
            VICBatchEndItem.QuantityOrdered := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyCurrentInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityRemaining := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyCompleteInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.QuantityUnposted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyToCompleteInDisplayUOM').AsValue().AsDecimal();
            VICBatchEndItem.UnitOfMeasure := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
            VICBatchEndItem.LotNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
            if Item.Get(VICBatchEndItem.ComponentId) then
                VICBatchEndItem.Description := Item.Description
            else
                VICBatchEndItem.Description := 'NOT FOUND';
            VICBatchEndItem.BinCode := '01';
            VICBatchEndItem.User := pcodUser;
            VICBatchEndItem.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VIC Web Api", 'OnFetchBatchConsumptions', '', false, false)]
    local procedure OnFetchBatchConsumptionsSubscriber(FacilityId: Text; BatchNumber: Text; pcodUser: Code[50])
    var
        Url: Text;
        VicinityApiUrl: Text;
        VicinityCompanyId: Text;
        VicinityUserId: Text;
        VicinityApiAccessKey: Text;
        VicinitySetup: Record "VIC Connector Setup";
        VICBatch: Record "VIC Batch To Scan";
        VICBatchConsumption: Record "VIC Batch Consumption To Scan";
        Item: Record Item;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ResponseString: Text;
        JsonTokenResponseString: JsonToken;
        JsonTokenBatchEndItem: JsonToken;
        JsonTokenBatchEndItems: JsonToken;
        JsonArrayBatchEndItems: JsonArray;
        JsonArrayBatchProcedures: JsonArray;

    begin
        VicinitySetup.Get();
        VicinityApiUrl := VicinitySetup.ApiUrl;
        VicinityCompanyId := VicinitySetup.CompanyId;
        VicinityUserId := VicinitySetup.ApiUserName;
        if (StrLen(VicinityUserId) = 0) then begin
            VicinityUserId := UserId;
        end;
        VICBatchConsumption.Reset();
        VICBatchConsumption.DeleteAll();
        VICBatchConsumption.SetCurrentKey(FacilityId, BatchNumber, LineIdNumber);

        // Get batch procedures.
        Url := StrSubstNo('%1/batch/%2/%3/%4/procedures', VicinityApiUrl, VicinityCompanyId, FacilityId, BatchNumber);
        Request.Method := 'GET';
        Request.SetRequestUri(Url);
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchConsumptionsSubscriber Client.Send error:\\' + GetLastErrorText);

        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        JsonArrayBatchProcedures := JsonTokenResponseString.AsArray();
        foreach JsonTokenBatchEndItem in JsonArrayBatchProcedures
        do begin
            if (GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText() <> '') then begin
                VICBatchConsumption.Init();
                VICBatchConsumption.FacilityId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
                VICBatchConsumption.BatchNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
                VICBatchConsumption.ScanType := "VIC Batch Scan Type"::Ingredient;
                VICBatchConsumption.ComponentId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText();
                VICBatchConsumption.LocationCode := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'SiteId').AsValue().AsText();
                VICBatchConsumption.LineIdNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();
                VICBatchConsumption.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityRemaining := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityUnposted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyToIssueInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.UnitOfMeasure := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
                VICBatchConsumption.LotNumber := ''; //GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
                if Item.Get(VICBatchConsumption.ComponentId) then
                    VICBatchConsumption.Description := Item.Description
                else
                    VICBatchConsumption.Description := 'NOT FOUND';
                VICBatchConsumption.BinCode := '01';
                VICBatchConsumption.User := pcodUser;
                VICBatchConsumption.Insert();
            end;
        end;

        // Get batch end item BOM
        Url := StrSubstNo('%1/batch/%2/%3/%4/bom', VicinityApiUrl, VicinityCompanyId, FacilityId, BatchNumber);
        System.Clear(Client);
        System.Clear(Request);
        Request.Method := 'GET';
        Request.SetRequestUri(Url);
        if not Client.Send(Request, Response) then
            Error('OnFetchBatchConsumptionsSubscriber Client.Send error:\\' + GetLastErrorText);

        Response.Content.ReadAs(ResponseString);
        JsonTokenResponseString.ReadFrom(ResponseString);
        JsonArrayBatchProcedures := JsonTokenResponseString.AsArray();
        foreach JsonTokenBatchEndItem in JsonArrayBatchProcedures
        do begin
            if (GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText() <> '') then begin
                VICBatchConsumption.Init();
                VICBatchConsumption.FacilityId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'FacilityId').AsValue().AsText();
                VICBatchConsumption.BatchNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'BatchNumber').AsValue().AsText();
                VICBatchConsumption.ScanType := "VIC Batch Scan Type"::EndItemBOM;
                VICBatchConsumption.ParentComponentId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'ComponentId').AsValue().AsText();
                VICBatchConsumption.ComponentId := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'SubComponentId').AsValue().AsText();
                VICBatchConsumption.LocationCode := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'SiteId').AsValue().AsText();
                VICBatchConsumption.LineIdNumber := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LineIdNumber').AsValue().AsInteger();
                VICBatchConsumption.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityRemaining := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyRemainingInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityCompleted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyIssuedInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.QuantityUnposted := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'QtyToIssueInDisplayUOM').AsValue().AsDecimal();
                VICBatchConsumption.UnitOfMeasure := GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'UnitId').AsValue().AsText();
                VICBatchConsumption.LotNumber := ''; //GetJsonToken(JsonTokenBatchEndItem.AsObject(), 'LotNumber').AsValue().AsText();
                if Item.Get(VICBatchConsumption.ComponentId) then
                    VICBatchConsumption.Description := Item.Description
                else
                    VICBatchConsumption.Description := 'NOT FOUND';
                VICBatchConsumption.BinCode := '01';
                VICBatchConsumption.Insert();
            end;
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
        VicinitySetup: Record "VIC Connector Setup";
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


    // procedure InitAndFetchBatchList()
    // var
    //     Url: Text;
    //     VicinityApiUrl: Text;
    //     VicinityCompanyId: Text;
    //     VicinityUserId: Text;
    //     VicinityApiAccessKey: Text;
    //     VicinitySetup: Record "Vicinity Setup";
    //     VICBatch: Record VICBatch;

    //     Client: HttpClient;
    //     Request: HttpRequestMessage;
    //     Response: HttpResponseMessage;
    //     ResponseString: Text;
    //     JsonTokenResponseString: JsonToken;
    //     JsonTokenBatch: JsonToken;
    // begin
    //     VICBatch.Reset();
    //     VICBatch.DeleteAll();
    //     VICBatch.SetCurrentKey(FacilityId, BatchNumber);



    //     if not VicinitySetup.Get() then begin
    //         Error('Vicinity Setup record does not exist')
    //     end;

    //     VicinityApiUrl := VicinitySetup.ApiUrl;
    //     VicinityCompanyId := VicinitySetup.CompanyId;
    //     VicinityUserId := VicinitySetup.ApiUserName;
    //     if (StrLen(VicinityUserId) = 0) then begin
    //         VicinityUserId := UserId;
    //     end;


    //     VicinityCompanyId := 'SA_BC';
    //     VicinityApiUrl := 'http://localhost:8085/VicinityWebPublic/api/vicinityservice';
    //     //        Url := VicinityApiUrl + '/planning/planningtransactions?companyId=' + VicinityCompanyId + '&userId=SABADY&componentId=' + ItemNo + ' &locationId=' + LocationCode + '&includeErpData=true';

    //     Url := StrSubstNo('%1/batch/%2/%3/list', VicinityApiUrl, VicinityCompanyId, 'CHICAGO');


    //     // RequestObject.Add('companyId', 'SA_BC');
    //     // RequestObject.Add('facilityId', 'CHICAGO');
    //     // RequestObject.WriteTo(JsonRequestData);
    //     // Content.WriteFrom(JsonRequestData);

    //     // Content.GetHeaders(Headers);
    //     // Headers.Clear();
    //     // Headers.Add('Content-Type', 'application/json');
    //     Request.Method := 'GET';
    //     Request.SetRequestUri(Url); // 'http://localhost:8085/VicinityWebPublic/api/vicinityservice/batch/SA_BC/CHICAGO/list');
    //     // Request.Content := Content;
    //     if not Client.Send(Request, Response) then
    //         Error('Unable to retrieve batches.');

    //     Response.Content.ReadAs(ResponseString);
    //     JsonTokenResponseString.ReadFrom(ResponseString);
    //     foreach JsonTokenBatch in JsonTokenResponseString.AsArray()
    //     do begin
    //         VICBatch.Init();
    //         VICBatch.FacilityId := GetJsonToken(JsonTokenBatch.AsObject(), 'FacilityId').AsValue().AsText();
    //         VICBatch.BatchNumber := GetJsonToken(JsonTokenBatch.AsObject(), 'BatchNumber').AsValue().AsText();
    //         VICBatch.BatchDescripton := GetJsonToken(JsonTokenBatch.AsObject(), 'Description').AsValue().AsText();
    //         SetDateFromJson(JsonTokenBatch, 'PlanStartDate', VICBatch.PlanStartDate);
    //         SetDateFromJson(JsonTokenBatch, 'PlanEndDate', VICBatch.PlanEndDate);
    //         SetDateFromJson(JsonTokenBatch, 'ActualStartDate', VICBatch.ActualStartDate);
    //         SetDateFromJson(JsonTokenBatch, 'ActualEndDate', VICBatch.ActualEndDate);
    //         VICBatch.ProcessingStage := BatchProcessingStage::Released;
    //         VICBatch.Status := BatchStatus::Active;
    //         VICBatch.Insert();
    //     end;
    // end;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Caption Class", 'OnResolveCaptionClass', '', true, true)]
    local procedure MyOnResolveCaptionClass(CaptionArea: Text; CaptionExpr: Text; Language: Integer; var Caption: Text; var Resolved: Boolean)
    begin
        if CaptionArea = '10' then begin
            Caption := 'GOOMBAH HELLO'; //GetCaption(CaptionExpr);
            Resolved := true;
        end;
    end;
}