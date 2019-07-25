table 75003 "Adiuto Electr. Doc."
{
    // version ADI.003


    fields
    {
        field(1;"Source No.";Integer)
        {
            Caption = 'Source No.';
            Description = 'ADI.001';
        }
        field(2;"Document No.";Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI.001';
        }
        field(3;IdUnivoco;Code[20])
        {
            Caption = 'IdUnivoco';
            Description = 'ADI.001';
        }
        field(4;"File Content";BLOB)
        {
            Caption = 'File Content';
            Description = 'ADI.001';
        }
        field(5;"File Name";Text[50])
        {
            Caption = 'File Name';
            Description = 'ADI.001';
        }
        field(6;Status;Code[50])
        {
            Caption = 'Status';
            Description = 'ADI.001';
        }
        field(7;Barcode;Code[50])
        {
            Caption = 'Barcode';
            Description = 'ADI.001';
        }
        field(8;"Table Id";Integer)
        {
            Caption = 'Id Tabella';
            Description = 'PC';
        }
    }

    keys
    {
        key(Key1;"Source No.","Document No.",IdUnivoco)
        {
        }
    }

    fieldgroups
    {
    }
}

