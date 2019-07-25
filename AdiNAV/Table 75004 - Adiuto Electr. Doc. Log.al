table 75004 "Adiuto Electr. Doc. Log"
{
    // version ADI.003

    Caption = 'Adiuto Electr. Doc. Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Nr. Movimento';
            Description = 'ADI.001';
        }
        field(2; "Source No."; Integer)
        {
            Caption = 'Source No.';
            Description = 'ADI.001';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI.001';
        }
        field(4; Barcode; Code[50])
        {
            Caption = 'Barcode';
            Description = 'ADI.001';
        }
        field(5; Operation; Text[30])
        {
            Caption = 'Operation';
            Description = 'ADI.001';
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'Assigned User ID';
            Description = 'ADI.001';
            TableRelation = "User Setup";
        }
        field(7; "Log Date Time"; DateTime)
        {
            Caption = 'Log Date Time';
            Description = 'ADI.001';
        }
        field(8; Note; Text[100])
        {
            Caption = 'Note';
            Description = 'ADI.001';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
    begin
        VALIDATE("Log Date Time", CURRENTDATETIME);
    end;

    procedure GetNextLineNo() rIntOutput: Integer
    var
    //        lRecAdiutoElectrInvLog: Record "75004";
    begin
        rIntOutput := 10;
        //        lRecAdiutoElectrInvLog.RESET;
        //        IF lRecAdiutoElectrInvLog.FINDLAST THEN
        //          rIntOutput+=lRecAdiutoElectrInvLog."Entry No.";
    end;
}

