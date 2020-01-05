%option noyywrap
%{
  #include "invoice.tab.h"
  int line_num = 1;
  int invoice_counter = 0;
  int CUSTOMER_COUNTER = 0;
  // Global Variables:
  //    Bussiness name:
  char BUSSINESS_NAME[128];
  FILE *FCustomer;
  FILE *FInvoice;
  FILE *FItems;
  //    Customer Information global variables:
  bool in_the_list;
  int CUSTOMER_ID;
  int CUSTOMER_ID_LIST[128]={0};
  char CUSTOMER_NAME[128];
  int CUSTOMER_ROAD_NUMBER;
  char CUSTOMER_ROAD[128];
  char CUSTOMER_CITY[128];
  char CUSTOMER_COUNTRY[128];
  int CUSTOMER_PHONE;
  //    Invoice Information global variables:
  char INV_ID_AREA[48];
  int INV_ID_NUMBER;
  int INV_ISSUE_DD;
  int INV_ISSUE_MM;
  int INV_ISSUE_YYYY;
  int INV_PON_1;
  int INV_PON_2;
  int INV_DUE_DD;
  int INV_DUE_MM;
  int INV_DUE_YYYY;
  int INV_TERM_TYPE;
  float INV_SUBTOTAL;
  float INV_VAT;
  float INV_TOTAL;
  // AMOUNT FOR TOTAL
  int PRODUCT_AMOUNT=0;
%}
%%
[ ]            {};
[ \t]+         { return TABLE;}
INVOICE        { return INVOICE; }
TO             { return TO;}
INVOICE#       { return INVOICE_NUM;}
DATE           { return DATE;}
P.O.#          { return ORDER_NUM;}
DUE            {return DUE;}
TERM           {return TERM;}
Net-           {return NET;}
ID	           {return ID;}
DESCRIPTION		 {return DESCRIPTION;}
QTY	           {return QTY;}
PRICE          {return UNIT_PRICE;}
AMOUNT         {return AMOUNT;}
Subtotal:       {return SUBTOTAL;}
VAT:	           {return VAT;}
Total:          {return TOTAL;}
[0-9]+\.[0-9]+ { yylval.fval = atof(yytext); return FLOAT; }
[0-9]+         { yylval.ival = atoi(yytext); return INT; }
[a-zA-Z ]+   {
  yylval.sval = strdup(yytext);
  return STRING;
}
\n             { ++line_num; return ENDL; }
-              { return DASH;}
.              ;
%%