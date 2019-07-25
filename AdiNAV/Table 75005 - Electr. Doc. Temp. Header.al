table 75005 "Electr. Doc. Temp. Header"
{
    // version ADI.003

    Caption = 'Electr. Doc. Temp. Header';

    fields
    {
        field(1; "Source No."; Integer)
        {
            Caption = 'Source No.';
            Description = 'ADI.001';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI.001';
        }
        field(3; IdUnivoco; Code[20])
        {
            Caption = 'IdUnivoco';
            Description = 'ADI.001';
        }
        field(4; Barcode; Code[50])
        {
            Caption = 'Barcode';
            Description = 'ADI.001';
        }
        field(100; "Reg. Date"; Date)
        {
            Caption = 'Reg. Date';
            Description = 'ADI.001';
        }
        field(101; "Reg. Time"; Time)
        {
            Caption = 'Reg. Time';
            Description = 'ADI.001';
        }
        field(102; "Reg. User Name"; Code[50])
        {
            Caption = 'User Name';
            Description = 'ADI.001';
        }
        field(103; "Reg. Source No."; Integer)
        {
            Caption = 'Reg. Nr. Sorgente';
            Description = 'ADI.001';
        }
        field(104; "Reg. Document No."; Code[20])
        {
            Caption = 'Document No.';
            Description = 'ADI.001';
        }
        field(105; "Reg. Document Type"; Integer)
        {
            Caption = 'Reg. Document Type';
            Description = 'ADI.001';
        }
        field(1000; "XML_1.1.1.1 IdPaese"; Text[2])
        {
        }
        field(1001; "XML_1.1.1.2 IdCodice"; Text[28])
        {
        }
        field(1002; "XML_1.1.2 Progr. Invio"; Text[10])
        {
        }
        field(1003; "XML_1.1.3 FormatoTrasmissione"; Text[5])
        {
        }
        field(1004; "XML_1.1.4 CodiceDestinatario"; Text[7])
        {
        }
        field(1005; "XML_1.1.6 PECDestinatario"; Text[250])
        {
            Description = 'ADI.001 (campo XML da 256 caratteri)';
        }
        field(1006; "XML_1.2.1.1.1 IdPaese"; Text[2])
        {
        }
        field(1007; "XML_1.2.1.1.2 IdCodice"; Text[28])
        {
        }
        field(1008; "XML_1.2.1.2 CodiceFiscale"; Text[16])
        {
        }
        field(1009; "XML_1.2.1.3.1 Denominazione"; Text[80])
        {
        }
        field(1010; "XML_1.2.1.3.2 Nome"; Text[60])
        {
        }
        field(1011; "XML_1.2.1.3.3 Cognome"; Text[60])
        {
        }
        field(1012; "XML_1.2.1.3.4 Titolo"; Text[10])
        {
        }
        field(1013; "XML_1.2.1.3.5 CodEORI"; Text[17])
        {
        }
        field(1014; "XML_1.2.2.1 Indirizzo"; Text[60])
        {
        }
        field(1015; "XML_1.2.2.2 NumeroCivico"; Text[8])
        {
        }
        field(1016; "XML_1.2.2.3 CAP"; Text[5])
        {
        }
        field(1017; "XML_1.2.2.4 Comune"; Text[60])
        {
        }
        field(1018; "XML_1.2.2.5 Provincia"; Text[2])
        {
        }
        field(1019; "XML_1.2.2.6 Nazione"; Text[2])
        {
        }
        field(1020; "XML_2.1.1.1 TipoDocumento"; Text[4])
        {
        }
        field(1021; "XML_2.1.1.2 Divisa"; Text[3])
        {
        }
        field(1022; "XML_2.1.1.3 Data"; Text[10])
        {
            Description = 'YYYY-MM-DD';
        }
        field(1023; "XML_2.1.1.4 Numero"; Text[20])
        {
        }
        field(1024; "XML_2.1.1.5.1 TipoRitenuta"; Text[4])
        {
        }
        field(1025; "XML_2.1.1.5.2 ImportoRitenuta"; Text[15])
        {
        }
        field(1026; "XML_2.1.1.5.3 AliquotaRitenuta"; Text[6])
        {
        }
        field(1027; "XML_2.1.1.5.4 CausalePagamento"; Text[2])
        {
        }
        field(1028; "XML_2.1.1.6.1 BolloVirtuale"; Text[2])
        {
        }
        field(1029; "XML_2.1.1.6.2 ImportoBollo"; Text[15])
        {
        }
        field(1030; "XML_2.1.1.9 Imp. Tot. Doc."; Text[15])
        {
        }
        field(1031; "XML_2.1.1.10 Arrotondamento"; Text[15])
        {
        }
        field(1032; "XML_2.1.2.6 CodiceCIG"; Text[15])
        {
        }
        field(1033; "XML_2.1.2.7 CodiceCUP"; Text[15])
        {
        }
        field(1034; "XML_2.4.1 CondizioniPagamento"; Text[4])
        {
        }
        field(1035; "XML_2.4.2.2 ModalitaPagamento"; Text[4])
        {
        }
        field(1036; "XML_2.4.2.5 DataScadPagamento"; Text[10])
        {
            Description = 'YYYY-MM-DD';
        }
        field(50000; "Table Id"; Integer)
        {
            Caption = 'Id Tabella';
        }
        field(50001; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(50002; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
            //                lRecAdiutoElectrInvManagement: Codeunit "75003";
            begin
                //                lRecAdiutoElectrInvManagement.SetVendorData("Buy-from Vendor No.", Rec);
            end;
        }
        field(50003; "Buy-from Vendor Name"; Text[50])
        {
            Caption = 'Buy-from Vendor Name';
            Editable = false;
            //            TableRelation = Vendor.Name WHERE (No.=FIELD(Buy-from Vendor No.));
            //This property is currently not supported
            //TestTableRelation = false;
            //            ValidateTableRelation = false;

            trigger OnValidate()
            var
            //                Vendor: Record "23";
            begin
            end;
        }
        field(50004; "Buy-from Vendor Name 2"; Text[50])
        {
            Caption = 'Buy-from Vendor Name 2';
            Editable = false;
            //            TableRelation = Vendor."Name 2" WHERE (No.=FIELD(Buy-from Vendor No.));
            //This property is currently not supported
            //TestTableRelation = false;
            //            ValidateTableRelation = false;
        }
        field(50005; "Buy-from Address"; Text[50])
        {
            Caption = 'Buy-from Address';
        }
        field(50006; "Buy-from Address 2"; Text[50])
        {
            Caption = 'Buy-from Address 2';
        }
        field(50007; "Buy-from City"; Text[30])
        {
            Caption = 'Buy-from City';
            //            TableRelation = IF (Buy-from Country/Region Code=CONST()) "Post Code".City
            //                            ELSE IF (Buy-from Country/Region Code=FILTER(<>'')) "Post Code".City WHERE (Country/Region Code=FIELD(Buy-from Country/Region Code));
            //This property is currently not supported
            //TestTableRelation = false;
            //            ValidateTableRelation = false;
        }
        field(50008; "Buy-from Contact"; Text[50])
        {
            Caption = 'Buy-from Contact';

            trigger OnLookup()
            var
            //                Contact: Record "5050";
            begin
            end;
        }
        field(50009; "Buy-from Post Code"; Code[20])
        {
            Caption = 'Buy-from Post Code';
            //            TableRelation = IF (Buy-from Country/Region Code=CONST()) "Post Code"
            //                            ELSE IF (Buy-from Country/Region Code=FILTER(<>'')) "Post Code" WHERE (Country/Region Code=FIELD(Buy-from Country/Region Code));
            //This property is currently not supported
            //TestTableRelation = false;
            //            ValidateTableRelation = false;
        }
        field(50010; "Buy-from County"; Text[30])
        {
            Caption = 'Buy-from County';
            //            TableRelation = County.Code;
            //This property is currently not supported
            //TestTableRelation = false;
            //            ValidateTableRelation = false;
        }
        field(50011; "Buy-from Country/Region Code"; Code[10])
        {
            Caption = 'Buy-from Country/Region Code';
            //            TableRelation = Country/Region;
        }
        field(50012; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(50013; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(50014; "Posting Date"; Date)
        {
            Caption = 'Posting Date';

            trigger OnValidate()
            var
                SkipJobCurrFactorUpdate: Boolean;
            begin
            end;
        }
        field(50015; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';

            trigger OnValidate()
            begin
                IF "Vendor Invoice No." <> '' THEN
                    TESTFIELD("Document Type", "Document Type"::Invoice);
            end;
        }
        field(50016; "Vendor Cr. Memo No."; Code[35])
        {
            Caption = 'Vendor Cr. Memo No.';

            trigger OnValidate()
            begin
                IF "Vendor Cr. Memo No." <> '' THEN
                    TESTFIELD("Document Type", "Document Type"::"Credit Memo");
            end;
        }
        field(50017; "Check Total"; Decimal)
        {
            AutoFormatExpression = "Buy-from Post Code";
            AutoFormatType = 1;
            Caption = 'Check Total';
        }
        field(50018; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(50019; "Electr. Doc.  No."; Code[10])
        {
            Caption = 'Electr. Doc.  No.';
        }
        field(50020; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(50021; "CIG Code"; Code[20])
        {
            Caption = 'CIG Code';
        }
        field(50022; "CUP Code"; Code[20])
        {
            Caption = 'CUP Code';
        }
    }

    keys
    {
        key(Key1; "Source No.", "Document No.", IdUnivoco)
        {
        }
    }

    fieldgroups
    {
    }
}

