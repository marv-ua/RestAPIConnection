# Counterparty address normalisation subsystem
## Enabling functionality
The user must have the "**Use of address normalisation**" role available for the functionality to be available
To enable the address normalisation functionality go to "**Administration**" - "**Using address normalisation**" section

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/404df01e-a650-4bff-84ef-c604818f4213)

In the window that opens, tick "**Using address normalisation**" and click **Save and close**

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/2604cb81-dd60-4963-bcf5-a6fd328e495e)

After that, the "**Address normalisation**" subsystem will appear in the menu

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/545df536-dd04-41b5-bd49-b3772032482c)

## Settings
To normalise addresses, a service is used, the connection settings and parameters of which are stored in the "Service connection settings" reference book

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/208b494b-fcd5-4af5-b4d2-24ae26fe314a)

Here you should specify the address of the service, the method to be used and the parameters used to call the method. 
For data transmission we specify a special value "**%1**" for the parameter (as it is done for the **q** parameter).

You can also specify the email address where the log of the service call will be sent.

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/22d90e09-10d9-4395-a22e-cf036f1b2c16)

## Use of functionality
To perform normalisation of counterparty addresses we use a queue where we add counterparties for which we need to perform normalisation. A counterparty may have several addresses on different dates, so normalisation will be performed on all addresses of the counterparty.
You can add or populate the counterparty queue by clicking on the "Counterparty address normalisation queue" link

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/2fec1f99-1b10-4ee2-9bd3-ddbfb42a19bb)

By clicking on the "**Fill the queue**" button - the queue will be filled with all counterparties.

**Start address normalisation** - starts the normalisation process

The result of normalisation will be filled in data of the Counterparty "**Address normalized**"

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/8c6074b6-2bd8-477a-9a7e-3ccca201f888)

## Reports
### The number of normalizations for the selected period
To generate this report - you need to use the Normalisation of counterparty addresses report
Select the "The number of normalisation for the selected period" report option

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/5041c1c1-93a6-4d04-8c42-a5e81c5241c7)

### The number of successful requests by country
To generate this report - you need to use the Normalisation of counterparty addresses report
Select the "The number of successful requests by country" report option

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/6c57611d-7db1-4c03-815a-c2e44c072bb0)

### Number of clients waiting for address normalization.
To generate this report - you need to use the Number of clients waiting for address normalization report

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/77982a81-a7eb-46a4-aa2c-803352c259d8)

You can see exactly who is in the normalisation queue using the decoding of the " Count" field

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/9f1a1209-808c-4619-b14a-3e27817d7c70)

Result:

![image](https://github.com/marv-ua/RestAPIConnection/assets/81148850/10755047-cd67-4096-8d5c-5e87ceb1cb46)




