page 50821 "VIC IW Batch Consumption List"
{
    Caption = 'Vicinity IW Consumption Batches';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = "VIC IW Batch";
    CardPageId = "VIC IW Batch Consumption";
    SourceTableView = sorting(BatchNumber, FacilityId) order(ascending);
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch Number"; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                }
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = All;
                }
                field("Formula ID"; Rec.FormulaId)
                {
                    ApplicationArea = All;
                }
                field("Batch Descripton"; Rec.BatchDescription)
                {
                    ApplicationArea = All;
                }
                field("Processing Stage"; Rec.ProcessingStage)
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Plan Start Date"; Rec.PlanStartDate)
                {
                    ApplicationArea = All;
                }
                field("Plan End Date"; Rec.PlanEndDate)
                {
                    ApplicationArea = All;
                }
                field("Actual Start Date"; Rec.ActualStartDate)
                {
                    ApplicationArea = All;
                }
                field("Actual End Date"; Rec.ActualEndDate)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Caption = 'P&ost';
                Image = PostOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTip = 'Write and post end-item output transactions to Vicinity.';

                trigger OnAction()

                begin
                    
                end;

                // trigger OnAction()
                // var
                //     BatchEndItem: Record VICBatchEndItem;
                //     VICPostBatch: Codeunit VICPostBatch;
                // begin
                //     // BatchEndItem.SetRange(FacilityId, Rec.FacilityId);
                //     // BatchEndItem.SetRange(BatchNumber, Rec.BatchNumber);
                //     if Dialog.Confirm('Do you want to post the batch?') then begin
                //         VICPostBatch.OnPostBatch(Rec.FacilityId, Rec.BatchNumber, Rec.PostThruToBC, PostDate);
                //         // Codeunit.Run(Codeunit::VICPostBatch, Rec);
                //         CurrPage.Update(false);
                //     end;
                // end;
            }
        }
    }

    trigger OnInit()
    var
        lcuVICWebServiceInterface: Codeunit "VIC Web Api";
        lrecVicinitySetup: Record "VIC Connector Setup";
    begin
        if not lrecVicinitySetup.Get() then begin
            Error('Vicinity Setup record does not exist.')
        end;
        if StrLen(lrecVicinitySetup.ApiUrl) = 0 then begin
            Error('Vicinity API URL has not been configured on the Vicinity Setup page.')
        end;
        lcuVICWebServiceInterface.OnFetchIWBatch(UserId);
    end;
}