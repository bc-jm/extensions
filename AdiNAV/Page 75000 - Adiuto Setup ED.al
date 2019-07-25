page 75000 "Adiuto Setup ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup';
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Adiuto Setup ED";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Ip Address"; "Ip Address")
                {
                }
                field(Port; Port)
                {
                }
                field(User; User)
                {
                }
                field(Password; Password)
                {
                    ExtendedDatatype = Masked;
                    Importance = Standard;
                }
                field("SDK Type"; "SDK Type")
                {
                }
                field("Path SDK"; "Path SDK")
                {
                }
                field("Enable Connected Users"; "Enable Connected Users")
                {
                }
                field(Enable; Enable)
                {
                }
            }
            group(Company)
            {
                Caption = 'Company';
                field("Company Id"; "Company Id")
                {
                }
                field("Field Company Id"; "Field Company Id")
                {
                }
                field("Field Company Name"; "Field Company Name")
                {
                }
                field("Value Field Company"; "Value Field Company")
                {

                    trigger OnAssistEdit()
                    begin
                        "Value Field Company" := COMPANYNAME;
                    end;
                }
            }
            group("NAV Table Setup")
            {
                Caption = 'NAV Table Setup';
                field("Connected User Field No."; "Connected User Field No.")
                {
                }
                field("Invoice Barcode Field No."; "Invoice Barcode Field No.")
                {
                }
                field("Delivery Barcode Field No."; "Delivery Barcode Field No.")
                {
                }
                field("Variation Note Field No."; "Variation Note Field No.")
                {
                }
                field("Duty Stamp Amount Field No."; "Duty Stamp Amount Field No.")
                {
                }
            }
            group("Purchases & Payables Setup")
            {
                Caption = 'Purchases & Payables Setup';
                field("Mandatory Invoice Barcode"; "Mandatory Invoice Barcode")
                {
                }
                field("Check Invoice Barcode Dup."; "Check Invoice Barcode Dup.")
                {
                }
                field("Mandatory Receipt Barcode"; "Mandatory Receipt Barcode")
                {
                }
                field("Check Rcpt. Barcode Duplicate"; "Check Rcpt. Barcode Duplicate")
                {
                }
                field("Electr. Doc. signed xml"; "Electr. Doc. signed xml")
                {
                }
                field("Electr. Doc. Currency Code"; "Electr. Doc. Currency Code")
                {
                }
                field("Electr. Doc. Export Path"; "Electr. Doc. Export Path")
                {
                }
                field("Electr. Doc. to Import Status"; "Electr. Doc. to Import Status")
                {
                }
                field("Electr. Doc. Imported Status"; "Electr. Doc. Imported Status")
                {
                }
                field("Electr. Doc. Pre-Reg. Enable"; "Electr. Doc. Pre-Reg. Enable")
                {
                }
                field("Electr. Doc. Pre-Reg. Status"; "Electr. Doc. Pre-Reg. Status")
                {
                }
                field("Electr. Doc. Registered Status"; "Electr. Doc. Registered Status")
                {
                }
                field("El. Doc. Posting Date"; "El. Doc. Posting Date")
                {
                }
                field("Electr. Doc. B2B Value"; "Electr. Doc. B2B Value")
                {
                }
            }
            group("Sales & Receivables Setup")
            {
                Caption = 'Sales & Receivables Setup';
                field("Mandatory Return Rcpt. Barcode"; "Mandatory Return Rcpt. Barcode")
                {
                }
                field("Check Return Rcpt. Duplicate"; "Check Return Rcpt. Duplicate")
                {
                }
                field("Multiple Publish"; "Multiple Publish")
                {
                }
                field("Electr. Doc. Start Status"; "Electr. Doc. Start Status")
                {
                }
                field("Electr. Doc. Publish Status"; "Electr. Doc. Publish Status")
                {
                }
                field("Electr. Doc. Delivery Status"; "Electr. Doc. Delivery Status")
                {
                }
            }
            part(AdiutoSetupDetail; 75001)
            {
                Caption = 'Documents';
                SubPageLink = "Primary Key" = FIELD ("Primary Key");
            }
        }
        area(factboxes)
        {
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END;
    end;

    var
        test: Text[1024];
}

