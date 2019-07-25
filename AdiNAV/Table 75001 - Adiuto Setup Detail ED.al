table 75001 "Adiuto Setup Detail ED"
{
    // version ADI.003

    Caption = 'Adiuto Setup Detail';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Table Id"; Integer)
        {
            Caption = 'NAV Table Id';
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Table));

            trigger OnLookup()
            var
                lRecAllObjWithCaption: Record "AllObjWithCaption";
                lPagObjects: Page Objects;
            begin
                lRecAllObjWithCaption.SETRANGE("Object Type", lRecAllObjWithCaption."Object Type"::Table);
                lRecAllObjWithCaption.SETFILTER("Object ID", '..1999999999|2000000004|2000000005');
                lPagObjects.SETTABLEVIEW(lRecAllObjWithCaption);
                lPagObjects.LOOKUPMODE(TRUE);
                IF lPagObjects.RUNMODAL = ACTION::LookupOK THEN BEGIN
                    lPagObjects.GETRECORD(lRecAllObjWithCaption);
                    VALIDATE("Table Id", lRecAllObjWithCaption."Object ID");
                END;
            end;

            trigger OnValidate()
            var
                lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
                Txt001: Label 'Child Rows Found.';
            begin
                lRecAdiutoSetupDetailLines.RESET;
                lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", "Primary Key");
                lRecAdiutoSetupDetailLines.SETRANGE("Line No.", "Line No.");
                IF lRecAdiutoSetupDetailLines.FINDFIRST THEN
                    ERROR(Txt001);
            end;
        }
        field(3; "Document Type"; Integer)
        {
            Caption = 'NAV Document Type';
        }
        field(4; "Create Document"; Boolean)
        {
            Caption = 'Create Document';
        }
        field(6; "Id Family Document"; Integer)
        {
            Caption = 'Id Family Document';

            trigger OnValidate()
            var
                lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
                Txt001: Label 'Child Rows Found';
            begin
                IF "Id Family Document" = 0 THEN BEGIN
                    VALIDATE("Name Family Document", '');
                END;

                lRecAdiutoSetupDetailLines.RESET;
                lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", "Primary Key");
                lRecAdiutoSetupDetailLines.SETRANGE("Line No.", "Line No.");
                IF lRecAdiutoSetupDetailLines.FINDFIRST THEN
                    ERROR(Txt001);

                TESTFIELD("El. Doc. Status Fld. Id", 0);
            end;
        }
        field(7; "Name Family Document"; Text[50])
        {
            Caption = 'Name Family Document';
        }
        field(12; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(15; "Email Adiuto"; Text[250])
        {
            Caption = 'Email Adiuto';
            Description = 'NOT USED';
        }
        field(17; "Report Id"; BigInteger)
        {
            Caption = 'NAV Report Id';
            Description = 'Report ID to file in Adiuto';
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Report));

            trigger OnValidate()
            begin
                IF "Report Id" > 0 THEN BEGIN
                    TESTFIELD(Phantom, FALSE);
                    IF "File Extension" = '' THEN
                        VALIDATE("File Extension", 'pdf');
                END;
            end;
        }
        field(18; "Field Name"; Text[50])
        {
            Caption = 'Field Name NAV';
            Editable = false;
        }
        field(19; "XML Document"; Option)
        {
            Caption = 'XML Invoice';
            OptionCaption = ' ,Active XML,Passive XML,Variation Note';
            OptionMembers = " ","Active XML","Passive XML","Variation Note";

            trigger OnValidate()
            var
                lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
                Text001: Label 'You can''t create more than one passive cycle reference to the same nav table id';
            begin
                IF ("XML Document" = "XML Document"::" ") OR
                  ("XML Document" = "XML Document"::"Variation Note") THEN
                    TESTFIELD("El. Doc. Status Fld. Id", 0)
                ELSE
                    VALIDATE("File Extension", 'xml');

                lRecAdiutoSetupDetail.RESET;
                lRecAdiutoSetupDetail.SETRANGE("XML Document", lRecAdiutoSetupDetail."XML Document"::"Passive XML");
                lRecAdiutoSetupDetail.SETRANGE("Table Id", "Table Id");
                IF lRecAdiutoSetupDetail.COUNT > 0 THEN
                    ERROR(Text001);
            end;
        }
        field(20; "Line No."; Integer)
        {
            Caption = 'Nr. Riga';
        }
        field(21; Phantom; Boolean)
        {
            Caption = 'Phantom';

            trigger OnValidate()
            begin
                TESTFIELD("Report Id", 0);
            end;
        }
        field(22; Canceled; Boolean)
        {
            Caption = 'Annullata';
        }
        field(23; "Total Detail Rows"; Integer)
        {
            CalcFormula = Count ("Adiuto Setup Detail Lines ED" WHERE ("Primary Key" = FIELD ("Primary Key"),
                                                                  "Line No." = FIELD ("Line No.")));
            Caption = 'Totale Righe Dettaglio';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "File Extension"; Text[5])
        {
            Caption = 'File Extension';
        }
        field(25; "El. Doc. Status Fld. Id"; Integer)
        {
            Caption = 'El. Doc. Status Fld. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. Status Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. Status Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(26; "El. Doc. Status Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. Status Fld. Name';
            Description = 'AC';
        }
        field(27; "El. Doc. Barcode Fld. Id"; Integer)
        {
            Caption = 'El. Doc. Status Fld. Id';
            Description = 'PC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. Barcode Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. Barcode Fld. Name", '')
                ELSE
                    TESTFIELD("XML Document", "XML Document"::"Passive XML");
            end;
        }
        field(28; "El. Doc. Barcode Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. Status Fld. Name';
            Description = 'PC';
        }
        field(29; "El. Doc. Attachment Report Id"; BigInteger)
        {
            Caption = 'El. Doc. Attachment Report Id';
            Description = 'AC';
            TableRelation = AllObj."Object ID" WHERE ("Object Type" = CONST (Report));
        }
        field(30; "El. Doc. Att. Rpt. Setup Code"; Code[10])
        {
            Caption = 'El. Doc. Att. Rpt. Setup Code';
            Description = 'AC';
        }
        field(31; "El. Doc. Trasmit. Fld. Id"; Integer)
        {
            Caption = 'El. Doc. Trasmit. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. Trasmit. Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. Trasmit. Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(32; "El. Doc. Trasmit. Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. Trasmit. Fld. Name';
            Description = 'AC';
        }
        field(33; "El. Doc. VAT Reg. Fld. Id"; Integer)
        {
            Caption = 'El. Doc. VAT Reg. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. VAT Reg. Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. VAT Reg. Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(34; "El. Doc. VAT Reg. Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. VAT Reg. Fld. Name';
            Description = 'AC';
        }
        field(35; "El. Doc. Progressive Fld. Id"; Integer)
        {
            Caption = 'El. Doc. Progressive Fld. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. Progressive Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. VAT Reg. Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(36; "El. Doc. Progressive Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. Progressive Fld. Name';
            Description = 'AC';
        }
        field(37; "El. Doc. Cust. Comp. Fld. Id"; Integer)
        {
            Caption = 'El. Doc. Cust. Comp. Fld. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. Progressive Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. VAT Reg. Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(38; "El. Doc. Cust. Comp. Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. Cust. Comp. Fld. Name';
            Description = 'AC';
        }
        field(39; "El. Doc. B2B Fld. Id"; Integer)
        {
            Caption = 'El. Doc. B2B Fld. Id';
            Description = 'AC';

            trigger OnValidate()
            begin
                TESTFIELD("Id Family Document");
                IF "El. Doc. B2B Fld. Id" = 0 THEN
                    VALIDATE("El. Doc. B2B Fld. Name", '')
                ELSE BEGIN
                    IF ("XML Document" <> "XML Document"::"Active XML") AND
                       ("XML Document" <> "XML Document"::"Passive XML") THEN
                        ERROR(STRSUBSTNO(Txt001, FIELDCAPTION("XML Document"), FORMAT("XML Document"::"Active XML"), FORMAT("XML Document"::"Passive XML")));
                END;
            end;
        }
        field(40; "El. Doc. B2B Fld. Name"; Text[30])
        {
            Caption = 'El. Doc. B2B Fld. Name';
            Description = 'AC';
        }
    }

    keys
    {
        key(Key1; "Primary Key", "Line No.")
        {
        }
        key(Key2; "Report Id")
        {
        }
        key(Key3; Description)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lRecAdiutoSetupDetailLines: Record "Adiuto Setup Detail Lines ED";
    begin
        lRecAdiutoSetupDetailLines.RESET;
        lRecAdiutoSetupDetailLines.SETRANGE("Primary Key", "Primary Key");
        lRecAdiutoSetupDetailLines.SETRANGE("Line No.", "Line No.");
        IF lRecAdiutoSetupDetailLines.FINDFIRST THEN
            lRecAdiutoSetupDetailLines.DELETEALL;
    end;

    trigger OnInsert()
    begin
        "Line No." := GetNextLineNo;
    end;

    trigger OnModify()
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
        lCtx001: Label 'Impossibile creare più documenti dalla stessa tabella';
    begin
        IF "Create Document" THEN BEGIN
            lRecAdiutoSetupDetail.SETRANGE("Primary Key", "Primary Key");
            lRecAdiutoSetupDetail.SETRANGE("Table Id", "Table Id");
            lRecAdiutoSetupDetail.SETRANGE("Document Type", "Document Type");
            lRecAdiutoSetupDetail.SETRANGE("Create Document", TRUE);
            IF lRecAdiutoSetupDetail.COUNT > 1 THEN
                ERROR(lCtx001);
        END;
        IF "Create Document" THEN
            TESTFIELD("File Extension");
    end;

    var
        Txt001: Label '%1 field value must be %2 or %3';

    local procedure GetNextLineNo() rIntNextLineNo: Integer
    var
        lRecAdiutoSetupDetail: Record "Adiuto Setup Detail ED";
    begin
        rIntNextLineNo := 1000;
        lRecAdiutoSetupDetail.RESET;
        lRecAdiutoSetupDetail.SETRANGE("Primary Key", "Primary Key");
        IF lRecAdiutoSetupDetail.FINDLAST THEN
            rIntNextLineNo += lRecAdiutoSetupDetail."Line No.";
    end;
}

