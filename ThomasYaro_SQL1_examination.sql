
--Thomas Yaro DE24 SQL 1 Inlämningsuppgift--


-- 1. Vi är i processen av att analysera våra kunders köphistorik. Kan du visa oss den totala 
 -- mängden kunden Sara Huiting har betalat för via faktura?
-- Ge oss kundens namn, och den totala summan (utan skatt) - 1p

SELECT cu.CustomerName, SUM(ct.AmountExcludingTax) AS TotalSum
FROM Sales.CustomerTransactions ct
INNER JOIN Sales.Customers cu ON ct.CustomerID = cu.CustomerID
WHERE CustomerName LIKE 'Sara Huiting'
GROUP BY cu.CustomerName


--2. Ge oss nu top 10 kunders totala köphistorik via faktura. Visa högst totalkostnad först. (utan skatt) - 1p


SELECT TOP 10 cu.CustomerName, SUM(ct.AmountExcludingTax) AS TotalSum
FROM Sales.CustomerTransactions ct
JOIN Sales.Customers cu ON ct.CustomerID = cu.CustomerID 
GROUP BY cu.CustomerName
ORDER BY SUM (ct.AmountExcludingTax) DESC


--3. Vi behöver se över vårt lager. Ge oss en rapport med produktnamn, aktuellt produktantal för 
-- varje produkt med ett nuvarande lagersaldo under 1000 och produktantalgränsen för när nyinventering bör ske. 
--Sortera på nuvarande lagersaldo i fallande ordning. - 1p


SELECT si.StockItemName, sih.QuantityOnHand, sih.ReorderLevel
FROM Warehouse.StockItemHoldings sih
JOIN Warehouse.StockItems si ON sih.StockItemID = si.StockItemID
WHERE QuantityOnHand <1000
ORDER BY QuantityOnHand DESC


--4. Hämta fakturaID, fakturadatum och totalbelopp (utan skatt) för fakturor med en totalsumma på över 10 000. - 1p


SELECT iv.InvoiceID, iv.InvoiceDate, SUM (ct.AmountExcludingTax) AS TotalSum
FROM Sales.Invoices iv
JOIN Sales.CustomerTransactions ct ON iv.InvoiceID = ct.InvoiceID
GROUP BY iv.InvoiceID, iv.InvoiceDate
HAVING SUM (ct.AmountExcludingTax) >10000


--5. Skriv ett query som visar alla slutpriser(med skatt, ta värden över 0) för transaktioner, samt räknar hur många gånger varje enskilt pris 
--förekommer i tabellen. Sortera så att högst antal förekommanden av priser är först - 1p


SELECT TransactionAmount, COUNT(*) AS NumberOfTimes
FROM Sales.CustomerTransactions
WHERE TransactionAmount > 0
GROUP BY TransactionAmount
ORDER BY COUNT (*) DESC


--6. Titta på specialrabatter. Utgå från rabatt med ID = 2 och gör sedan ett räkneexempel. 
--Ta ner rabatten från procent till decimalform och räkna ut det nya priset efter applicerad rabatt, för en fiktiv produkt som kostar 565kr. - 1p


SELECT DiscountPercentage / 100 AS DiscountDecimalForm, 565 - (565 * (DiscountPercentage/100)) AS NewPrice
FROM Sales.SpecialDeals
WHERE SpecialDealID = 2


--7. Skriv en SQL-fråga som hämtar de två köpleveransgssmetoderna som är mest populära(mest använda). Visa även antal gånger dessa använts på beställningar och sortera
--så att högst antal förekommanden är först. - 1p
																					    


SELECT TOP (2) dm.DeliveryMethodName, COUNT(*) AS DeliveryMethodUsed
  FROM Purchasing.PurchaseOrders po
  INNER JOIN Application.DeliveryMethods dm ON po.DeliveryMethodID = dm.DeliveryMethodID
  GROUP BY dm.DeliveryMethodName
  ORDER BY DeliveryMethodUsed DESC;


--8. Som nyanställda behöver ni registreras i databasen. Lägg in ert namn och övrig relevant information i Application.People tabellen 
--på liknande sätt som andra registrerade anställda. Fokusera enbart på de kolumner som inte tillåter null värden just nu, resterande kolumner kan vi ta vid senare tillfälle. 
--Låt P.K, Search Name och Datum hanteras automatiskt. Ni får logga in, men är inte External logon provider och heller inte försäljare. Låt LastEditedBy referera till id 1.  - 2p


INSERT INTO Application.People
       (FullName, PreferredName, IsPermittedToLogon, IsExternalLogonProvider, IsSystemUser, IsEmployee, IsSalesperson, LastEditedBy)
VALUES ('Thomas Yaro', 'Tompa', 1, 0, 1, 1, 0, 1)

SELECT *
FROM Application.People


--9. Vi behöver lägga några nya färger i databasen. Färgerna är: Turquoise, Lime Green, Pink och Jade. 
--Skriv en query för att lägga till de nya färgerna. Ni måste även referera senast ändringen (LastEditedBy) till ert personliga PersonID 2p


INSERT INTO Warehouse.Colors(Colorname, LastEditedBy)
VALUES 
('Turquoise', 3262), 
('Lime Green', 3262),
('Pink', 3262),
('Jade', 3262)

select *
FROM Warehouse.Colors

--10. Det blev en misskommunikation och vi behöver inte den nya färgen Lime Green. Var snäll och radera den från databasen.  2p


DELETE FROM Warehouse.Colors
WHERE ColorName LIKE 'Lime Green'


--11. Vad är det minsta enhetspriset för en orderrad år 2013? Visa orderdatum(OrderDate) i YEAR och det minsta enhetspriset. Ta bort dubletter. - 2p


SELECT DISTINCT MIN(ol.UnitPrice) AS MinUnitPrice, YEAR(od.Orderdate) AS OrderYear
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders od ON ol.OrderID = od.OrderID
WHERE YEAR (od.OrderDate) = 2013
GROUP BY YEAR (od.orderDate)


--12. Hämta en lista över alla orders som är plockade (PickingCompletedWhen är inte null) och som innehåller produkter som 
--har ett enhetspris högre än det genomsnittliga enhetspriset för alla orderrader. Visa OrderId och enhetspris - 2p


SELECT od.orderid, ol.UnitPrice
FROM Sales.Orders od
INNER JOIN Sales.OrderLines ol ON od.OrderID = ol.OrderID
WHERE od.PickingCompletedWhen IS NOT NULL
AND ol.UnitPrice > (SELECT AVG(UnitPrice) from Sales.OrderLines)
ORDER BY od.OrderID


--13. Skapa ett index i en tabell med över 50 00 poster. Välj en kolumn som inte redan har ett index. 
--Skriv därefter ett query som inehåller och använder sig av indexerad kolumn och visar exekveringstid i messages. 2p  


CREATE INDEX OrderDate
ON Sales.Orders (OrderDate);
SET STATISTICS TIME ON;

SELECT OrderID, CustomerID, OrderDate, ExpectedDeliveryDate
FROM Sales.Orders
WHERE OrderDate >= '2013-01-01' AND OrderDate <= '2016-12-31'
ORDER BY OrderDate;
SET STATISTICS TIME OFF;


--14. Visa produkter i lagret med ett enhetspris mellan 5 och 20 och typisk vikt per enhet mellan 0.1 och 0.4. Sortera på enhetspris stigande.
--Därefter, skriv ett nytt query under som räknar totala antalet produkter som uppfyller villkoren av första frågan. - 2p


SELECT StockItemName, UnitPrice, TypicalWeightPerUnit
FROM Warehouse.StockItems
WHERE UnitPrice BETWEEN 5 AND 20
  AND TypicalWeightPerUnit BETWEEN 0.1 AND 0.4
ORDER BY UnitPrice ASC;

SELECT COUNT(*) AS TotalProducts
FROM Warehouse.StockItems
WHERE UnitPrice BETWEEN 5 AND 20 AND TypicalWeightPerUnit BETWEEN 0.1 AND 0.4;



--15. Lägg ihop kunder och transaktioner. Vi vill se: KundID, Kundnamn som endast inehåller 4 första tecknen och sedan en sammanfogad order summary. 
--Exmpel på hur order summary ska se ut: Before tax: $100 - Total: $150 - 2p. Ta endast transaktionsvärden över 0.


SELECT cu.CustomerID, LEFT (cu.CustomerName, 4) AS CustomerName,
CONCAT ('Before Tax: $', ct.AmountExcludingTax, ' - Total: $', ct.TransactionAmount) AS OrderSummary
FROM Sales.Customers cu
INNER JOIN Sales.CustomerTransactions ct ON cu.CustomerID = ct.CustomerID
WHERE ct.TransactionAmount > 0


--16. Visa KundID och och kundnamn. Sätt därefter ihop en kontaktinfo som ser ut såhär: Contact: (111) 111-1111 | Url: http//www.aaaaaaa.com.
-- Visa endast kunder som har en kundkategori som innehåller 'store'. Visa även kategorin. - 2p


SELECT cu.CustomerID, cu.CustomerName, cc.CustomerCategoryName,
CONCAT ('Contact: ', cu.PhoneNumber, ' | Url: ', cu.WebsiteURL) AS PhoneAndWebsite
FROM Sales.Customers cu
INNER JOIN Sales.CustomerCategories cc ON cu.CustomerCategoryID = cc.CustomerCategoryID
WHERE cc.CustomerCategoryName LIKE '%Store%'


--17. Vi vill se VILKA det var som senaste redigerade information om länder. Sätt ihop person och länder-tabellerna och visa endast personers id och namn, därefter,
-- visa alla övriga kolumner från länder. Ta bara med länder i Europa och Asien och ta bort personid 1. Sortera stigande på giltigt datum.  - 2p


SELECT pp.PersonID, pp.FullName, ct.LastEditedBy, ct.*
FROM Application.Countries ct
INNER JOIN Application.People pp ON ct.LastEditedBy = pp.PersonID
WHERE (ct.Continent = 'Europe' OR ct.Continent = 'Asia') AND pp.PersonID <> 1
ORDER BY ct.ValidFrom ASC


--18. Vi behöver uppdatera uppgifter för en av våra registrerade personer.
-- Han är tidigare registrerad som Daniel Magnusson och har precis blivit anställd hos oss. Han är numera en systemanvändare, anställd och försäljare,
-- Daniel bytte dock nyligen efternamn till Franzén. Se till att uppdatera hans nya efternamn. 
-- Han ska ha möjlighet attt logga in och har tilldelats ett arbetsmail: danielf@wideworldimporters.com
-- Se till att göra detta till hans login och uppdatera även tidigare registrerad mail. - 2p


UPDATE Application.People
SET FullName = 'Daniel Franzén', IsPermittedToLogon = 1, IsSystemUser = 1, IsEmployee = 1, IsSalesperson = 1, LogonName = 'danielf@wideworldimporters.com', EmailAddress = 'danielf@wideworldimporters.com'
WHERE PersonID = 1383

SELECT *
FROM Application.People
WHERE PersonID = 1383


--19. Skapa en valfri Stored Procedure(SP) med två inputvärden och en inner join som du tycker passar. Demonstrera användandet av den därefter. 3p

GO
CREATE OR ALTER PROCEDURE GetPopularStockItems
    @MinPrice DECIMAL(10, 2),
    @MaxSoldItems INT
AS
BEGIN
    SELECT si.StockItemID, si.StockItemName, si.UnitPrice, SUM(ol.Quantity) AS TotalSold
    FROM Warehouse.StockItems si
    INNER JOIN Sales.OrderLines ol ON si.StockItemID = ol.StockItemID
    WHERE si.UnitPrice BETWEEN @MinPrice AND 1000
    GROUP BY si.StockItemID, si.StockItemName, si.UnitPrice
    HAVING SUM(ol.Quantity) >= @MaxSoldItems
    ORDER BY TotalSold DESC;
END;

EXEC GetPopularStockItems @MinPrice = 10, @MaxSoldItems = 50


--20. Skriv en fråga som visar kundnamn och kundkategori för alla kunder som hade transaktioner under året 2014. För varje kund, visa:
--Kundens namn i stora bokstäver.
--Kundkategori.
--Den totala summan av transaktioner (utan skatt) för 2014, avrundat till noll decimaler.
--Det genomsnittliga transaktionsbeloppet(utan skatt) för 2014, avrundat till en decimal. - 3p


SELECT UPPER (cu.CustomerName) AS CustomerName, (cc.CustomerCategoryName),
       CAST(ROUND(SUM(ct.AmountExcludingTax),0) AS DECIMAL (18,0)) AS TotalTransactions,
       CAST(ROUND(AVG(ct.AmountExcludingTax),1) AS DECIMAL (18,1)) AS AverageAmounts
FROM Sales.Customers cu
INNER JOIN Sales.CustomerCategories cc ON cu.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Sales.CustomerTransactions ct ON cu.CustomerID = ct.CustomerID
WHERE YEAR(ct.TransactionDate) = 2014
GROUP BY cu.CustomerName, cc.CustomerCategoryName
ORDER BY TotalTransactions DESC


--21. Skriv en fråga som visar information om produkter (StockItems) som har haft transaktioner under året 2014. För varje produkt visa:
--Produktens namn (StockItemName) i små bokstäver.
--Färg på produkten (ColorName). Ta med alla StockItems även de som inte har en matchning med color.
--Antalet gånger en transaktion med produkten förekommit under året.
--Den totala kvantiteten som förekom i transaktioner under året. Ta endast ingående produktkvantitet(inga minustal).
--Den genomsnittliga kvantiteten per transaktion, avrundad till noll decimaler.
--Sortera resultatet i fallande ordning efter totalt antal sålda enheter. 3p


SELECT LOWER(si.StockItemName) AS ProductName, co.ColorName,
COUNT(st.StockItemTransactionID) AS TransactionCount,
SUM(st.Quantity) AS TotalQuantity, 
CAST(ROUND(AVG(st.Quantity),0) AS DECIMAL (18,0)) AS AverageQuantity
FROM Warehouse.StockItems si
INNER JOIN Warehouse.StockItemTransactions st ON si.StockItemID = st.StockItemID
LEFT JOIN Warehouse.Colors co ON si.ColorID = co.ColorID
WHERE st.Quantity >=0 AND YEAR (st.TransactionOccurredWhen) = 2014
GROUP BY si.StockItemName, co.ColorName
ORDER BY TotalQuantity DESC


--22. Vi har noterat att en vanlig förekommande rapport är översikt kring våra kunders fakturor och transaktioner. Kan du skapa en view som innehåller: 
--kundnamn, kundkategori, fakturaID, fakturadatum, summa (utan skatt) och levereringsinstruktioner. Filtrera bort kostnader under 1000 (utan skatt)
-- Skriv ett query som skapar denna view med ett passande namn och sedan ett query som använder sig av samma view och även filtrerar på kostnad (utan skatt) fallande. - 3p


GO
CREATE OR ALTER VIEW CustomerInvoiceSummary AS
SELECT cu.CustomerName, cc.CustomerCategoryName, si.InvoiceID, si.InvoiceDate, so.DeliveryInstructions, ct.AmountExcludingTax AS Sum
FROM Sales.Customers cu
INNER JOIN Sales.Invoices si ON cu.CustomerID = si.CustomerID
INNER JOIN Sales.CustomerCategories cc ON cu.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Sales.CustomerTransactions ct ON si.InvoiceID = ct.InvoiceID
LEFT JOIN Sales.Orders so ON cu.CustomerID = so.CustomerID
WHERE ct.AmountExcludingTax >= 1000
GO

SELECT *
FROM CustomerInvoiceSummary
ORDER BY Sum DESC


--23. Titta på beställningar och beräkna det genomsnittliga enhetspriset per kundID år 2013. Visa sedan endast rader med ett genomsnittligt enhetspris lika med och över 60 -3p


SELECT CustomerID, AVG(ol.UnitPrice) AS AveragePrice
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders so ON ol.OrderID = so.OrderID
WHERE YEAR(so.OrderDate) = 2013
GROUP BY so.CustomerID
HAVING AVG(ol.UnitPrice) >= 60


--24. Skriv en query som hämtar CustomerID, en kolumn kallad "OrderCount" som räknar antalet beställningar varje kund har gjort,
--en kolumn kallad "AvgOrderValue" som visar det genomsnittliga enhetspriset på en orderrad avrundat till två decimaler, samt en kolumn kallad 
--"CustomerSummary" som innehåller en sammanfattning i formatet "Customer [CustomerID] - Orders: [OrderCount] - Avg: $[AvgOrderValue]". 
--Filtrera för kunder som har lagt fler eller lika med 100 beställningar och sortera resultatet i fallande ordning efter AvgOrderValue. - 3p


SELECT od.CustomerID, COUNT(od.OrderID) AS OrderCount, 
CAST(ROUND(AVG(ol.UnitPrice),2) AS DECIMAL (18,2)) AS AvgOrderValue,
CONCAT('Customer: ', od.CustomerID, ' - Orders: ',COUNT(od.OrderID), ' - Avg: $', ROUND(AVG(ol.UnitPrice), 2)) AS CustomerSummary
FROM Sales.Orders od
INNER JOIN Sales.OrderLines ol ON od.OrderID = ol.OrderID
GROUP BY od.customerID
HAVING COUNT(od.OrderID) >= 100
ORDER BY AvgOrderValue DESC


-- 25. Skriv en query som hämtar CustomerID, CustomerName, antalet beställningar per kund, samt det totala beloppet (enhetspris gånger kvantitet) 
--för alla deras beställningar av items i kategorin 'Clothing'. Filtrera för kunder vars totala belopp är större än 10 000 
--och sortera resultatet i fallande ordning efter totalbeloppet. - 3p


SELECT ct.CustomerID, ct.CustomerName, COUNT(od.OrderID) AS TotalOrders, SUM(ol.UnitPrice * ol.Quantity) AS TotalAmount
FROM Sales.Customers ct
INNER JOIN Sales.Orders od ON ct.CustomerID = od.CustomerID
INNER JOIN Sales.OrderLines ol ON od.OrderID = ol.OrderID
INNER JOIN Warehouse.StockItemStockGroups sit ON ol.StockItemID = sit.StockItemID
INNER JOIN Warehouse.StockGroups sg ON sit.StockGroupID = sg.StockGroupID
WHERE sg.StockGroupName = 'Clothing'
GROUP BY ct.CustomerID, ct.CustomerName
HAVING SUM(ol.UnitPrice * ol.Quantity) >10000
ORDER BY TotalAmount DESC