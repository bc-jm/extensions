table 75002 "Adiuto Setup Detail Lines ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup Detail Lines';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "NAV Field Id"; Integer)
        {
            Caption = 'NAV Field Id';
            TableRelation = "Field"."No." WHERE (Class = FILTER (Normal .. FlowField));
        }
        field(4; "NAV Field Name"; Text[30])
        {
            Caption = 'NAV Field Name';
        }
        field(5; "Adiuto Field Id"; Integer)
        {
            Caption = 'Adiuto Field Id';
        }
        field(6; "Adiuto Field Name"; Text[30])
        {
            Caption = 'Adiuto Field Name';
        }
        field(7; "Use for Insertion"; Boolean)
        {
            Caption = 'Use for Insertion';

            trigger OnValidate()
            var
                lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
            begin
                IF lRecAdiutoSetupDetail.GET("Primary Key", "Line No.") THEN BEGIN
                    IF lRecAdiutoSetupDetail."XML Document" = lRecAdiutoSetupDetail."XML Document"::" " THEN
                        lRecAdiutoSetupDetail.TESTFIELD("Create Document");
                END ELSE
                    ERROR('');
            end;
        }
        field(8; "Use for Searching"; Boolean)
        {
            Caption = 'Use for Searching';
        }
        field(9; "Use for Update"; Boolean)
        {
            Caption = 'Use for Update';
        }
        field(10; "Decimal Separator"; Text[1])
        {
            Caption = 'Decimal Separator';
        }
    }

    keys
    {
        key(Key1; "Primary Key", "Line No.", "NAV Field Id")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
    begin
        IF lRecAdiutoSetupDetail.GET("Primary Key", "Line No.") THEN BEGIN
            lRecAdiutoSetupDetail.TESTFIELD("Table Id");
            lRecAdiutoSetupDetail.TESTFIELD("Id Family Document");
        END ELSE
            ERROR('');
    end;

    var
        gNavTableId: Integer;

    procedure GetAdiutoFamilyId() rIntFamilyId: Integer
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
    begin
        rIntFamilyId := 0;
        IF lRecAdiutoSetupDetail.GET("Primary Key", "Line No.") THEN
            rIntFamilyId := lRecAdiutoSetupDetail."Id Family Document";
    end;

    procedure GetNavTableId() rIntTableId: Integer
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
    begin
        rIntTableId := 0;
        IF lRecAdiutoSetupDetail.GET("Primary Key", "Line No.") THEN
            rIntTableId := lRecAdiutoSetupDetail."Table Id";
    end;
}

