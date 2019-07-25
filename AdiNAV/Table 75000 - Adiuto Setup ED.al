table 75000 "Adiuto Setup ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Ip Address"; Text[250])
        {
            Caption = 'Ip Address';
        }
        field(3; Port; Integer)
        {
            Caption = 'Port';
        }
        field(4; User; Text[30])
        {
            Caption = 'User';
        }
        field(5; Password; Text[30])
        {
            Caption = 'Password';
        }
        field(7; "Path SDK"; Text[250])
        {
            Caption = 'Path SDK';
        }
        field(10; "Field Company Id"; Integer)
        {
            Caption = 'Field Company Id';
        }
        field(11; "Field Company Name"; Text[30])
        {
            Caption = 'Field Company Name';
        }
        field(12; "Value Field Company"; Text[50])
        {
            Caption = 'Value Field Company';
        }
        field(15; Enable; Boolean)
        {
            Caption = 'Enable';
        }
        field(16; "Enable Connected Users"; Boolean)
        {
            Caption = 'Enable Connected Users';
        }
        field(20; "Mandatory Invoice Barcode"; Boolean)
        {
            Caption = 'Mandatory Invoice Barcode';
        }
        field(21; "Check Invoice Barcode Dup."; Boolean)
        {
            Caption = 'Check Invoice Duplicated Barcode ';
        }
        field(22; "Mandatory Receipt Barcode"; Boolean)
        {
            Caption = 'Mandatory Receipt Barcode';
        }
        field(23; "Check Rcpt. Barcode Duplicate"; Boolean)
        {
            Caption = 'Check Rcpt. Duplicated Barcode';
        }
        field(24; "Mandatory Return Rcpt. Barcode"; Boolean)
        {
            Caption = 'Mandatory Return Rcpt. Barcode';
        }
        field(25; "Check Return Rcpt. Duplicate"; Boolean)
        {
            Caption = 'Check Return Rcpt. Duplicated Barcode';
        }
        field(26; "Electr. Doc. Start Status"; Code[20])
        {
            Caption = 'Electr. Doc. Start Status';
            Description = 'AC';
        }
        field(27; "Electr. Doc. Publish Status"; Code[20])
        {
            Caption = 'Electr. Doc. Publish Status';
            Description = 'AC';
        }
        field(28; "Electr. Doc. Finish Status"; Code[20])
        {
            Caption = 'Electr. Doc. Finish Status';
            Description = 'PC';
        }
        field(29; "Multiple Publish"; Boolean)
        {
            Caption = 'Multiple Publish';
            Description = 'AC';
        }
        field(30; "Electr. Doc. to Import Status"; Code[20])
        {
            Caption = 'Electr. Doc. Finish Status';
            Description = 'PC';
        }
        field(31; "Electr. Doc. Imported Status"; Code[20])
        {
            Caption = 'Electr. Doc. Imported';
            Description = 'PC';
        }
        field(32; "Electr. Doc. Export Path"; Text[250])
        {
            Caption = 'Electr. Doc. Export Path';
            Description = 'PC';
        }
        field(33; "Electr. Doc. Pre-Reg. Enable"; Boolean)
        {
            Caption = 'Electr. Doc. Pre. Reg. Enable';
            Description = 'PC';
        }
        field(34; "Electr. Doc. Pre-Reg. Status"; Code[20])
        {
            Caption = 'Electr. Doc. Pre-Reg. Status';
            Description = 'PC';
        }
        field(35; "Electr. Doc. Registered Status"; Code[20])
        {
            Caption = 'Electr. Doc. Registered Status';
            Description = 'PC';
        }
        field(36; "Electr. Doc. Currency Code"; Code[10])
        {
            Caption = 'Electr. Doc. Currency Code';
            Description = 'PC';
        }
        field(37; "SDK Type"; Option)
        {
            Caption = 'Tipo SDK';
            OptionCaption = ' ,Standard,Web';
            OptionMembers = " ",Standard,Web;
        }
        field(38; "Company Id"; Integer)
        {
            Caption = 'Company Id';
        }
        field(39; "Invoice Barcode Field No."; Integer)
        {
            Caption = 'Invoice Barcode Field No.';
        }
        field(40; "Delivery Barcode Field No."; Integer)
        {
            Caption = 'Delivery Barcode Field No.';
        }
        field(41; "Connected User Field No."; Integer)
        {
            Caption = 'Connected User Field No.';
        }
        field(42; "Variation Note Field No."; Integer)
        {
            Caption = 'Variation Note Field No.';
        }
        field(43; "Electr. Doc. signed xml"; Option)
        {
            Caption = 'Doc. Elettronico firma XML';
            Description = 'PC';
            OptionCaption = 'Standard,Xades';
            OptionMembers = Standard,Xades;
        }
        field(44; "Electr. Doc. Delivery Status"; Code[20])
        {
            Caption = 'Electr. Doc. Delivery Status';
            Description = 'PC';
        }
        field(45; "Duty Stamp Amount Field No."; Integer)
        {
            Caption = 'Duty Stamp Amount Field No.';
        }
        field(46; "El. Doc. Posting Date"; Option)
        {
            Caption = 'El. Doc. Posting Date';
            Description = 'PC';
            OptionCaption = ' ,Workdate,Document date,End Month Document date';
            OptionMembers = " ",Workdate,"Document date","End Month Document date";
        }
        field(47; "Electr. Doc. B2B Value"; Code[20])
        {
            Caption = 'Electr. Doc. B2B Value';
            Description = 'PC';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

