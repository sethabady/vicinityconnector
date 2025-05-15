codeunit 50900 "VIC IW Handler"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 23044908, 'OnBeforeProcessEvent', '', true, true)]
    local procedure OnBeforeProcessEventSubscriber(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    var
        lcuWHICommon: CodeUnit "WHI Common Functions";
    begin
        case piEventID of 21000:
            Test(piEventID, precEventParams, pbtxtOutput, pbOverrideWHI);
        end;
    end;
    
    local procedure Test(piEventID: Integer; var precEventParams: Record "IWX Event Param"; var pbtxtOutput: BigText; var pbOverrideWHI: Boolean)
    begin
            pbOverrideWHI := true ;
            pbtxtOutput.AddText('HELLO FROM OnBeforeProcessEventSubscriber');
    end;
   
}