namespace vicinityconnector.vicinityconnector;

page 50800 "VIC Connector Setup"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Vicinity Connector Setup';
    PageType = Card;
    SourceTable = "VIC Connector Setup";
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Vicinity Enabled"; Rec."Vicinity Enabled")
                {
                    ApplicationArea = All;
                }
                field("Gen. Journal Batch"; Rec."Gen. Journal Batch")
                {
                    ApplicationArea = All;
                }

                field("Item Journal Batch"; Rec."Item Journal Batch")
                {
                    ApplicationArea = All;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Warehousing Enabled"; Rec."Warehousing Enabled")
                {
                    Visible = false;
                    ApplicationArea = All;
                }

                field("Warehouse Journal Batch"; Rec."Warehouse Journal Batch")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API URL"; Rec."ApiUrl")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity Company ID"; Rec."CompanyId")
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API User Name"; Rec.ApiUserName)
                {
                    Visible = true;
                    ApplicationArea = All;
                }
                field("Vicinity API Access Key"; Rec.ApiAccessKey)
                {
                    ExtendedDatatype = Masked;
                    Visible = true;
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
