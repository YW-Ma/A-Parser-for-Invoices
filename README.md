# A Parser for Invoices
 Based on Flex and Bison, we created a parser for date importing from invoices.
# Tutorial
- Thanks to the excellent [tutorial](https://aquamentus.com/flex_bison.html) privided by Chris verBurg!

- This tutorial explained __the functions of \*.y and \*.l files__ in details, and also provides useful instructions for __the usage of global variables and yyerror__.

- I strongly recommend a beginner of flex & bison to take a look at the [tutorial](https://aquamentus.com/flex_bison.html).

# Usage
1. Preparing your tools
- install __Flex__ and __Bison__: input `sudo apt-get install flex bison`
- install __make__ if necessary: input `sudo apt-get install make` (I have upload a Makefile for Ubuntu)
2. Downloading the source code
- `clone` this repository or simply download the zip file from this page.
-  open this repository in your terminal.
3. Compiling
- input `cd Parser` step into the folder of our parser.
- input `make invoice` compile the parser.
4. Test
- there are seven samples of invoice in the file `invoice.samples.txt`
- create a folder named Tables if you cannot find it in the folder Parser .
- input `./invoice` in your terminal to parse all invoices. Three tables will be created, containing information of each customer, invoice and entry of invoice.
- Attention, items in \*.tab file is divided by Tab. though they may appear to be irregualr in your editor, they will become cells of a table if you open it with Excel, Numbers, or Libra Office tool.

# Meanings
1. Work flow we supposed: 

_Invoices --(Scanner) -->images--(OCR)--> textfiles  __--(Parser)-->__ tables in datebase_;

We focused on the construction of Parser in this work.

# Features
1. providing specific error information telling where and what the error is.
2. semantic checking for unit price and total price in invoices.
