page 50804 "VIC Batch Output"
{
    Caption = 'Batch Outputs';
    PageType = Document;
    //    ApplicationArea = All;
    //    UsageCategory = Tasks;
    SourceTable = "VIC Batch To Scan";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Facility ID"; Rec.FacilityId)
                {
                    ApplicationArea = All;
                    Caption = 'Facility ID';
                    Editable = false;
                }
                field("Batch Number"; Rec.BatchNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Number';
                    Editable = false;
                }
                field("User"; Rec.User)
                {
                    ApplicationArea = All;
                    Caption = 'User';
                    Editable = false;
                }

                field("Batch Description"; Rec.BatchDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Description';
                    Editable = false;
                }
                field("Processing Stage"; Rec.ProcessingStage)
                {
                    ApplicationArea = All;
                    Caption = 'Processing Stage';
                    Editable = false;
                }
                field("Batch Status"; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Batch Status';
                    Editable = false;
                }
                field("Plan Start Date"; Rec.PlanStartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Plan Start Date';
                    Editable = false;
                }
                field("Plan End Date"; Rec.PlanEndDate)
                {
                    ApplicationArea = All;
                    Caption = 'Plan End Date';
                    Editable = false;
                }
                field("Actual Start Date"; Rec.ActualStartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Actual Start Date';
                    Editable = false;
                }
                field("Actual End Date"; Rec.ActualEndDate)
                {
                    ApplicationArea = All;
                    Caption = 'Actual End Date';
                    Editable = false;
                }
                field("Post Date"; PostDate)
                {
                    ApplicationArea = All;
                    Caption = 'Post Date';
                }
                field("Post Thru to BC"; Rec.PostThruToBC)
                {
                    ApplicationArea = All;
                    Caption = 'Post Thru to BC';
                }
            }
            part(EndItems; "VIC Batch Output SubForm")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                SubPageLink = FacilityId = field(FacilityId), BatchNumber = field(BatchNumber);
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
                ToolTip = 'Write and post end-item completion transactions to Vicinity.';

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

    var
        PostDate: Date;

    trigger OnAfterGetCurrRecord()
    var
        VICWebServiceInterface: Codeunit "VIC Web Api";
    begin
        PostDate := System.Today();
        VICWebServiceInterface.OnFetchBatchEndItems(Rec.FacilityId, Rec.BatchNumber, UserId);
    end;
}