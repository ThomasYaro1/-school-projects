
--Thomas Yaro DE24 SQL 1 Inl�mningsuppgift--


-- 1. Vi �r i processen av att analysera v�ra kunders k�phistorik. Kan du visa oss den totala 
 -- m�ngden kunden Sara Huiting har betalat f�r via faktura?
-- Ge oss kundens namn, och den totala summan (utan skatt) - 1p

SELECT cu.CustomerName, SUM(ct.AmountExcludingTax) AS TotalSum
FROM Sales.CustomerTransactions ct
INNER JOIN Sales.Customers cu ON ct.CustomerID = cu.CustomerID
WHERE CustomerName LIKE 'Sara Huiting'
GROUP BY cu.CustomerName


--2. Ge oss nu top 10 kunders totala k�phistorik via faktura. Visa h�gst totalkostnad f�rst. (utan skatt) - 1p


SELECT TOP 10 cu.CustomerName, SUM(ct.AmountExcludingTax) AS TotalSum
FROM Sales.CustomerTransactions ct
JOIN Sales.Customers cu ON ct.CustomerID = cu.CustomerID 
GROUP BY cu.CustomerName
ORDER BY SUM (ct.AmountExcludingTax) DESC


--3. Vi beh�ver se �ver v�rt lager. Ge oss en rapport med produktnamn, aktuellt produktantal f�r 
-- varje produkt med ett nuvarande lagersaldo under 1000 och produktantalgr�nsen f�r n�r nyinventering b�r ske. 
--Sortera p� nuvarande lagersaldo i fallande ordning. - 1p


SELECT si.StockItemName, sih.QuantityOnHand, sih.ReorderLevel
FROM Warehouse.StockItemHoldings sih
JOIN Warehouse.StockItems si ON sih.StockItemID = si.StockItemID
WHERE QuantityOnHand <1000
ORDER BY QuantityOnHand DESC


--4. H�mta fakturaID, fakturadatum och totalbelopp (utan skatt) f�r fakturor med en totalsumma p� �ver 10 000. - 1p


SELECT iv.InvoiceID, iv.InvoiceDate, SUM (ct.AmountExcludingTax) AS TotalSum
FROM Sales.Invoices iv
JOIN Sales.CustomerTransactions ct ON iv.InvoiceID = ct.InvoiceID
GROUP BY iv.InvoiceID, iv.InvoiceDate
HAVING SUM (ct.AmountExcludingTax) >10000


--5. Skriv ett query som visar alla slutpriser(med skatt, ta v�rden �ver 0) f�r transaktioner, samt r�knar hur m�nga g�nger varje enskilt pris 
--f�rekommer i tabellen. Sortera s� att h�gst antal f�rekommanden av priser �r f�rst - 1p


SELECT TransactionAmount, COUNT(*) AS NumberOfTimes
FROM Sales.CustomerTransactions
WHERE TransactionAmount > 0
GROUP BY TransactionAmount
ORDER BY COUNT (*) DESC


--6. Titta p� specialrabatter. Utg� fr�n rabatt med ID = 2 och g�r sedan ett r�kneexempel. 
--Ta ner rabatten fr�n procent till decimalform och r�kna ut det nya priset efter applicerad rabatt, f�r en fiktiv produkt som kostar 565kr. - 1p


SELECT DiscountPercentage / 100 AS DiscountDecimalForm, 565 - (565 * (DiscountPercentage/100)) AS NewPrice
FROM Sales.SpecialDeals
WHERE SpecialDealID = 2


--7. Skriv en SQL-fr�ga som h�mtar de tv� k�pleveransgssmetoderna som �r mest popul�ra(mest anv�nda). Visa �ven antal g�nger dessa anv�nts p� best�llningar och sortera
--s� att h�gst antal f�rekommanden �r f�rst. - 1p
																					    


SELECT TOP (2) dm.DeliveryMethodName, COUNT(*) AS DeliveryMethodUsed
  FROM Purchasing.PurchaseOrders po
  INNER JOIN Application.DeliveryMethods dm ON po.DeliveryMethodID = dm.DeliveryMethodID
  GROUP BY dm.DeliveryMethodName
  ORDER BY DeliveryMethodUsed DESC;


--8. Som nyanst�llda beh�ver ni registreras i databasen. L�gg in ert namn och �vrig relevant information i Application.People tabellen 
--p� liknande s�tt som andra registrerade anst�llda. Fokusera enbart p� de kolumner som inte till�ter null v�rden just nu, resterande kolumner kan vi ta vid senare tillf�lle. 
--L�t P.K, Search Name och Datum hanteras automatiskt. Ni f�r logga in, men �r inte External logon provider och heller inte f�rs�ljare. L�t LastEditedBy referera till id 1.  - 2p


INSERT INTO Application.People
       (FullName, PreferredName, IsPermittedToLogon, IsExternalLogonProvider, IsSystemUser, IsEmployee, IsSalesperson, LastEditedBy)
VALUES ('Thomas Yaro', 'Tompa', 1, 0, 1, 1, 0, 1)

SELECT *
FROM Application.People


--9. Vi beh�ver l�gga n�gra nya f�rger i databasen. F�rgerna �r: Turquoise, Lime Green, Pink och Jade. 
--Skriv en query f�r att l�gga till de nya f�rgerna. Ni m�ste �ven referera senast �ndringen (LastEditedBy) till ert personliga PersonID 2p


INSERT INTO Warehouse.Colors(Colorname, LastEditedBy)
VALUES 
('Turquoise', 3262), 
('Lime Green', 3262),
('Pink', 3262),
('Jade', 3262)

select *
FROM Warehouse.Colors

--10. Det blev en misskommunikation och vi beh�ver inte den nya f�rgen Lime Green. Var sn�ll och radera den fr�n databasen.  2p


DELETE FROM Warehouse.Colors
WHERE ColorName LIKE 'Lime Green'


--11. Vad �r det minsta enhetspriset f�r en orderrad �r 2013? Visa orderdatum(OrderDate) i YEAR och det minsta enhetspriset. Ta bort dubletter. - 2p


SELECT DISTINCT MIN(ol.UnitPrice) AS MinUnitPrice, YEAR(od.Orderdate) AS OrderYear
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders od ON ol.OrderID = od.OrderID
WHERE YEAR (od.OrderDate) = 2013
GROUP BY YEAR (od.orderDate)


--12. H�mta en lista �ver alla orders som �r plockade (PickingCompletedWhen �r inte null) och som inneh�ller produkter som 
--har ett enhetspris h�gre �n det genomsnittliga enhetspriset f�r alla orderrader. Visa OrderId och enhetspris - 2p


SELECT od.orderid, ol.UnitPrice
FROM Sales.Orders od
INNER JOIN Sales.OrderLines ol ON od.OrderID = ol.OrderID
WHERE od.PickingCompletedWhen IS NOT NULL
AND ol.UnitPrice > (SELECT AVG(UnitPrice) from Sales.OrderLines)
ORDER BY od.OrderID


--13. Skapa ett index i en tabell med �ver 50 00 poster. V�lj en kolumn som inte redan har ett index. 
--Skriv d�refter ett query som ineh�ller och anv�nder sig av indexerad kolumn och visar exekveringstid i messages. 2p  


CREATE INDEX OrderDate
ON Sales.Orders (OrderDate);
SET STATISTICS TIME ON;

SELECT OrderID, CustomerID, OrderDate, ExpectedDeliveryDate
FROM Sales.Orders
WHERE OrderDate >= '2013-01-01' AND OrderDate <= '2016-12-31'
ORDER BY OrderDate;
SET STATISTICS TIME OFF;


--14. Visa produkter i lagret med ett enhetspris mellan 5 och 20 och typisk vikt per enhet mellan 0.1 och 0.4. Sortera p� enhetspris stigande.
--D�refter, skriv ett nytt query under som r�knar totala antalet produkter som uppfyller villkoren av f�rsta fr�gan. - 2p


SELECT StockItemName, UnitPrice, TypicalWeightPerUnit
FROM Warehouse.StockItems
WHERE UnitPrice BETWEEN 5 AND 20
  AND TypicalWeightPerUnit BETWEEN 0.1 AND 0.4
ORDER BY UnitPrice ASC;

SELECT COUNT(*) AS TotalProducts
FROM Warehouse.StockItems
WHERE UnitPrice BETWEEN 5 AND 20 AND TypicalWeightPerUnit BETWEEN 0.1 AND 0.4;



--15. L�gg ihop kunder och transaktioner. Vi vill se: KundID, Kundnamn som endast ineh�ller 4 f�rsta tecknen och sedan en sammanfogad order summary. 
--Exmpel p� hur order summary ska se ut: Before tax: $100 - Total: $150 - 2p. Ta endast transaktionsv�rden �ver 0.


SELECT cu.CustomerID, LEFT (cu.CustomerName, 4) AS CustomerName,
CONCAT ('Before Tax: $', ct.AmountExcludingTax, ' - Total: $', ct.TransactionAmount) AS OrderSummary
FROM Sales.Customers cu
INNER JOIN Sales.CustomerTransactions ct ON cu.CustomerID = ct.CustomerID
WHERE ct.TransactionAmount > 0


--16. Visa KundID och och kundnamn. S�tt d�refter ihop en kontaktinfo som ser ut s�h�r: Contact: (111) 111-1111 | Url: http//www.aaaaaaa.com.
-- Visa endast kunder som har en kundkategori som inneh�ller 'store'. Visa �ven kategorin. - 2p


SELECT cu.CustomerID, cu.CustomerName, cc.CustomerCategoryName,
CONCAT ('Contact: ', cu.PhoneNumber, ' | Url: ', cu.WebsiteURL) AS PhoneAndWebsite
FROM Sales.Customers cu
INNER JOIN Sales.CustomerCategories cc ON cu.CustomerCategoryID = cc.CustomerCategoryID
WHERE cc.CustomerCategoryName LIKE '%Store%'


--17. Vi vill se VILKA det var som senaste redigerade information om l�nder. S�tt ihop person och l�nder-tabellerna och visa endast personers id och namn, d�refter,
-- visa alla �vriga kolumner fr�n l�nder. Ta bara med l�nder i Europa och Asien och ta bort personid 1. Sortera stigande p� giltigt datum.  - 2p


SELECT pp.PersonID, pp.FullName, ct.LastEditedBy, ct.*
FROM Application.Countries ct
INNER JOIN Application.People pp ON ct.LastEditedBy = pp.PersonID
WHERE (ct.Continent = 'Europe' OR ct.Continent = 'Asia') AND pp.PersonID <> 1
ORDER BY ct.ValidFrom ASC


--18. Vi beh�ver uppdatera uppgifter f�r en av v�ra registrerade personer.
-- Han �r tidigare registrerad som Daniel Magnusson och har precis blivit anst�lld hos oss. Han �r numera en systemanv�ndare, anst�lld och f�rs�ljare,
-- Daniel bytte dock nyligen efternamn till Franz�n. Se till att uppdatera hans nya efternamn. 
-- Han ska ha m�jlighet attt logga in och har tilldelats ett arbetsmail: danielf@wideworldimporters.com
-- Se till att g�ra detta till hans login och uppdatera �ven tidigare registrerad mail. - 2p


UPDATE Application.People
SET FullName = 'Daniel Franz�n', IsPermittedToLogon = 1, IsSystemUser = 1, IsEmployee = 1, IsSalesperson = 1, LogonName = 'danielf@wideworldimporters.com', EmailAddress = 'danielf@wideworldimporters.com'
WHERE PersonID = 1383

SELECT *
FROM Application.People
WHERE PersonID = 1383


--19. Skapa en valfri Stored Procedure(SP) med tv� inputv�rden och en inner join som du tycker passar. Demonstrera anv�ndandet av den d�refter. 3p

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


--20. Skriv en fr�ga som visar kundnamn och kundkategori f�r alla kunder som hade transaktioner under �ret 2014. F�r varje kund, visa:
--Kundens namn i stora bokst�ver.
--Kundkategori.
--Den totala summan av transaktioner (utan skatt) f�r 2014, avrundat till noll decimaler.
--Det genomsnittliga transaktionsbeloppet(utan skatt) f�r 2014, avrundat till en decimal. - 3p


SELECT UPPER (cu.CustomerName) AS CustomerName, (cc.CustomerCategoryName),
       CAST(ROUND(SUM(ct.AmountExcludingTax),0) AS DECIMAL (18,0)) AS TotalTransactions,
       CAST(ROUND(AVG(ct.AmountExcludingTax),1) AS DECIMAL (18,1)) AS AverageAmounts
FROM Sales.Customers cu
INNER JOIN Sales.CustomerCategories cc ON cu.CustomerCategoryID = cc.CustomerCategoryID
INNER JOIN Sales.CustomerTransactions ct ON cu.CustomerID = ct.CustomerID
WHERE YEAR(ct.TransactionDate) = 2014
GROUP BY cu.CustomerName, cc.CustomerCategoryName
ORDER BY TotalTransactions DESC


--21. Skriv en fr�ga som visar information om produkter (StockItems) som har haft transaktioner under �ret 2014. F�r varje produkt visa:
--Produktens namn (StockItemName) i sm� bokst�ver.
--F�rg p� produkten (ColorName). Ta med alla StockItems �ven de som inte har en matchning med color.
--Antalet g�nger en transaktion med produkten f�rekommit under �ret.
--Den totala kvantiteten som f�rekom i transaktioner under �ret. Ta endast ing�ende produktkvantitet(inga minustal).
--Den genomsnittliga kvantiteten per transaktion, avrundad till noll decimaler.
--Sortera resultatet i fallande ordning efter totalt antal s�lda enheter. 3p


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


--22. Vi har noterat att en vanlig f�rekommande rapport �r �versikt kring v�ra kunders fakturor och transaktioner. Kan du skapa en view som inneh�ller: 
--kundnamn, kundkategori, fakturaID, fakturadatum, summa (utan skatt) och levereringsinstruktioner. Filtrera bort kostnader under 1000 (utan skatt)
-- Skriv ett query som skapar denna view med ett passande namn och sedan ett query som anv�nder sig av samma view och �ven filtrerar p� kostnad (utan skatt) fallande. - 3p


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


--23. Titta p� best�llningar och ber�kna det genomsnittliga enhetspriset per kundID �r 2013. Visa sedan endast rader med ett genomsnittligt enhetspris lika med och �ver 60 -3p


SELECT CustomerID, AVG(ol.UnitPrice) AS AveragePrice
FROM Sales.OrderLines ol
INNER JOIN Sales.Orders so ON ol.OrderID = so.OrderID
WHERE YEAR(so.OrderDate) = 2013
GROUP BY so.CustomerID
HAVING AVG(ol.UnitPrice) >= 60


--24. Skriv en query som h�mtar CustomerID, en kolumn kallad "OrderCount" som r�knar antalet best�llningar varje kund har gjort,
--en kolumn kallad "AvgOrderValue" som visar det genomsnittliga enhetspriset p� en orderrad avrundat till tv� decimaler, samt en kolumn kallad 
--"CustomerSummary" som inneh�ller en sammanfattning i formatet "Customer [CustomerID] - Orders: [OrderCount] - Avg: $[AvgOrderValue]". 
--Filtrera f�r kunder som har lagt fler eller lika med 100 best�llningar och sortera resultatet i fallande ordning efter AvgOrderValue. - 3p


SELECT od.CustomerID, COUNT(od.OrderID) AS OrderCount, 
CAST(ROUND(AVG(ol.UnitPrice),2) AS DECIMAL (18,2)) AS AvgOrderValue,
CONCAT('Customer: ', od.CustomerID, ' - Orders: ',COUNT(od.OrderID), ' - Avg: $', ROUND(AVG(ol.UnitPrice), 2)) AS CustomerSummary
FROM Sales.Orders od
INNER JOIN Sales.OrderLines ol ON od.OrderID = ol.OrderID
GROUP BY od.customerID
HAVING COUNT(od.OrderID) >= 100
ORDER BY AvgOrderValue DESC


-- 25. Skriv en query som h�mtar CustomerID, CustomerName, antalet best�llningar per kund, samt det totala beloppet (enhetspris g�nger kvantitet) 
--f�r alla deras best�llningar av items i kategorin 'Clothing'. Filtrera f�r kunder vars totala belopp �r st�rre �n 10 000 
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