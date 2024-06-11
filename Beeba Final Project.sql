-- Drop tables
/* DROP TABLE Inventory_Supply;
DROP TABLE Inventory;
DROP TABLE Feedback;
DROP TABLE Creative_Staff;
DROP TABLE Manager;
DROP TABLE Customer_Service_Agent;
DROP TABLE Sales_Staff;
DROP TABLE Employee;
DROP TABLE Order_Purchase;
DROP TABLE Order_Purchase_Line;
DROP TABLE Self_Designed_Product;
DROP TABLE Licensed_Product;
DROP TABLE Collaborative_Product;
DROP TABLE Collaborate;
DROP TABLE Work;
DROP TABLE Order_Purchase;
DROP TABLE Supplier;
DROP TABLE Product;
DROP TABLE In_Store_Customer;
DROP TABLE Online_Customer;
DROP TABLE Customer;*/

-- Create CUSTOMER Table 
CREATE TABLE Customer_T (
    CustomerID NUMERIC(11,0) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    CustomerAddress VARCHAR(255),
    CustomerPhoneNumber CHAR(14),
    CustomerEmailAddress VARCHAR(255),
    CustomerType CHAR(1),
    CONSTRAINT Customer_PK PRIMARY KEY (CustomerID)
);

-- Create ONLINE CUSTOMER Table 
CREATE TABLE OnlineCustomer_T (
    CustomerID NUMERIC(11,0) NOT NULL,
    AccountCreationDate DATETIME,
    OnlinePaymentPreference VARCHAR(50),
    OnlineShoppingHistory VARCHAR(2000),
    OnlineBrowsingHistory VARCHAR(2000),
    OnlineAccountUsername VARCHAR(50),
    OnlineAccountPassword VARCHAR(255),
    CONSTRAINT OnlineCustomer_PK PRIMARY KEY (CustomerID),
    CONSTRAINT OnlineCustomer_FK1 FOREIGN KEY (CustomerID) REFERENCES Customer_T(CustomerID),
    CONSTRAINT OnlineUsername UNIQUE (OnlineAccountUsername),
    CONSTRAINT ChkOnlineUsername CHECK (
        OnlineAccountUsername LIKE '[a-zA-Z0-9._%-]%' AND
        OnlineAccountUsername NOT LIKE '%[^a-zA-Z0-9._%-]%' AND
        -- at least 8 characters
        LEN(OnlineAccountUsername) >= 8 AND 
        -- at least one lowercase letter
        OnlineAccountUsername LIKE '%[a-z]%' AND 
        -- at least one uppercase letter
        OnlineAccountUsername LIKE '%[A-Z]%' AND 
        -- at least one digit
        OnlineAccountUsername LIKE '%[0-9]%' AND 
        -- at least one special character from given set
        (OnlineAccountUsername LIKE '%_%' OR 
         OnlineAccountUsername LIKE '%-%' OR
         OnlineAccountUsername LIKE '%.%')  
    )
);

-- Create IN-STORE CUSTOMER Table 
CREATE TABLE InStoreCustomer_T (
    CustomerID NUMERIC(11,0) NOT NULL,
    PreferredBoutique VARCHAR(255),
    InStoreVisitFrequency INT,
    InStorePurchaseHistory VARCHAR(2000), 
    CONSTRAINT InStoreCustomer_PK PRIMARY KEY (CustomerID),
    CONSTRAINT InStoreCustomer_FK1 FOREIGN KEY (CustomerID) REFERENCES Customer_T(CustomerID)
);

-- Create PRODUCT Table 
CREATE TABLE Product_T (
    ProductID NUMERIC(11,0) NOT NULL,
    ProductName VARCHAR(255) NOT NULL,
    ProductDescription VARCHAR(2000), 
    -- Price must be non-negative
    ProductPrice DECIMAL(10,2) CHECK (ProductPrice >= 0),  
    ProductCategory VARCHAR(50),
    CONSTRAINT Product_PK PRIMARY KEY (ProductID)
);

-- Create COLLABORATIVE PRODUCT Table
CREATE TABLE CollaborativeProduct_T (
    ProductID NUMERIC(11,0) NOT NULL,
    CollaborationStartDate DATE,
    CollaborationEndDate DATE,
    CollaborationTerms VARCHAR(2000),  -- Descriptions of collaboration terms
    CollaborativeProductTeam VARCHAR(255),
    CONSTRAINT CollaborativeProduct_PK PRIMARY KEY (ProductID),
    CONSTRAINT CollaborativeProduct_FK1 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID), 
	CONSTRAINT CollabDateTimeSpan CHECK (
		-- Using DATEADD function to add two months to the start date
        CollaborationEndDate = DATEADD(month, 2, CollaborationStartDate)
    )
);

-- Create SELF-DESIGNED PRODUCT Table 
CREATE TABLE SelfDesignedProduct_T (
    ProductID NUMERIC(11,0) NOT NULL,
    DesignTeamName VARCHAR(100),
    ProductionMethod VARCHAR(2000),  
    CONSTRAINT SelfDesignedProduct_PK PRIMARY KEY (ProductID),
    CONSTRAINT SelfDesignedProduct_FK1 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID)
);

-- Create SUPPLIER Table
 CREATE TABLE Supplier_T (
    SupplierID NUMERIC(11,0) NOT NULL,
    SupplierCompName VARCHAR(100) NOT NULL,
    SupplierEmailAdress VARCHAR(255) NOT NULL,
    SupplierPhoneNumber CHAR(14) NOT NULL,
    SupplierAddress VARCHAR(255) NOT NULL,
    CONSTRAINT Supplier_PK PRIMARY KEY (SupplierID)
);

-- Create LICENSED PRODUCT Table
CREATE TABLE LicensedProduct_T (
    ProductID NUMERIC(11,0) NOT NULL,
    LicenseHolder VARCHAR(100) NOT NULL,
    LicenseTerms VARCHAR(4000) NOT NULL,
    RateOfRoyalty DECIMAL(5,2) NOT NULL 
    CHECK (RateOfRoyalty >= 0 AND RateOfRoyalty <= 100),
    CONSTRAINT LicensedProduct_PK PRIMARY KEY (ProductID),
    CONSTRAINT LicensedProduct_FK1 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID)
);

-- Create ORDER-PURCHASE Table
CREATE TABLE OrderPurchase_T (
    OrderPurchaseID NUMERIC(11,0) NOT NULL,
    CustomerID NUMERIC(11,0) NOT NULL,
    OrderPurchaseDate DATETIME NOT NULL DEFAULT GETDATE(),    
    OrderPurchaseTotalCost DECIMAL(10,2) NOT NULL CHECK (OrderPurchaseTotalCost>= 0), 
    OrderPurchaseStatus VARCHAR(50) NOT NULL CHECK (OrderPurchaseStatus IN ('Pending', 'Completed')),  
    CONSTRAINT OrderPurchase_PK PRIMARY KEY (OrderPurchaseID),
    CONSTRAINT OrderPurchase_FK1 FOREIGN KEY (CustomerID) REFERENCES Customer_T(CustomerID) 
);

-- Create ORDER-PURCHASE LINE Table
CREATE TABLE OrderPurchaseLine_T (
    OrderPurchaseLineID NUMERIC(11,0) NOT NULL,
    OrderPurchaseID NUMERIC(11,0) NOT NULL,
    ProductID NUMERIC(11,0) NOT NULL,
    OrderPurchaseLineProductUnit INT NOT NULL CHECK (OrderPurchaseLineProductUnit > 0),  
    OrderPurchaseLineUnitCost DECIMAL(10,2) NOT NULL CHECK (OrderPurchaseLineUnitCost >= 0),  
    OrderPurchaseLineTotalCost DECIMAL(10,2) NOT NULL,
    CONSTRAINT OrderPurchaseLine_PK PRIMARY KEY (OrderPurchaseLineID),
    CONSTRAINT OrderPurchaseLine_FK1 FOREIGN KEY (OrderPurchaseID) REFERENCES OrderPurchase_T(OrderPurchaseID),  
    CONSTRAINT OrderPurchaseLine_FK2 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID)
);

-- Create EMPLOYEE Table 
CREATE TABLE Employee_T (
    EmployeeID NUMERIC(11,0) NOT NULL,
    EmployeeName VARCHAR(100) NOT NULL,
    EmployeeHireDate DATE NOT NULL,
    EmployeeSalary DECIMAL(10,2) CHECK (EmployeeSalary >= 0),  
    EmployeeRole VARCHAR(50) NOT NULL,
    CONSTRAINT Employee_PK PRIMARY KEY (EmployeeID), 
    CONSTRAINT SatisfactoryEmployeeRoleName CHECK (
        EmployeeRole IN ('Manager', 'Sales Staff', 'Customer Service Agent', 'Creative Staff')
    ) 
);

-- Create CUSTOMER SERVICE AGENT Table
CREATE TABLE CustomerServiceAgent_T (
    EmployeeID NUMERIC(11,0) NOT NULL,
    CustomerInquiryCount INT,
    CONSTRAINT Customer_Service_Agent_PK PRIMARY KEY (EmployeeID),
    CONSTRAINT CustomerServiceAgent_FK1 FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID)
);

-- Create MANAGER Table
CREATE TABLE Manager_T (
    EmployeeID NUMERIC(11,0) NOT NULL,
    -- below is from unary relationship 
    HigherLevelManagerID NUMERIC(11,0), 
    OperationalTasks NVARCHAR(1000),
    CONSTRAINT Manager_PK PRIMARY KEY (EmployeeID),
    CONSTRAINT Manager_FK1 FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID),
    CONSTRAINT Manager_FK2 FOREIGN KEY (HigherLevelManagerID) REFERENCES Employee_T(EmployeeID) 
);

-- Create CREATIVE STAFF Table
CREATE TABLE CreativeStaff_T (
    EmployeeID NUMERIC(11,0) NOT NULL,
    SpecializationArea NVARCHAR(100),
    YearsofExp INT,
    CONSTRAINT CreativeStaff_PK PRIMARY KEY (EmployeeID),
    CONSTRAINT CreativeStaff_FK1 FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID)
);

-- Create SALES STAFF Tabe
CREATE TABLE SalesStaff_T (
    EmployeeID NUMERIC(11,0) NOT NULL,
    SalesTrainingCompletionDate DATE,
    SalesTrainingName NVARCHAR(100),
    SalesStaffAssignedLocation NVARCHAR(100),
    CONSTRAINT SalesStaff_PK PRIMARY KEY (EmployeeID),
    CONSTRAINT SalesStaff_FK1 FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID), 
    CONSTRAINT SatisfactoryAssignedLocation CHECK (RIGHT(SalesStaffAssignedLocation, 6) = 'Branch')
);

-- Create COLLABORATE Table
CREATE TABLE Collaborate_T (
    ProductID NUMERIC(11,0) NOT NULL,
    EmployeeID NUMERIC(11,0) NOT NULL,
    CONSTRAINT Collaborate_PK PRIMARY KEY (ProductID, EmployeeID),
    CONSTRAINT CollaborateProduct_FK FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID),
    CONSTRAINT CollaborateEmployee_FK FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID)
);

-- Create WORK Table
CREATE TABLE Work_T (
    ProductID NUMERIC(11,0) NOT NULL,
    EmployeeID NUMERIC(11,0) NOT NULL,
    Role VARCHAR(100),
    CONSTRAINT Work_PK PRIMARY KEY (ProductID, EmployeeID),
    CONSTRAINT WorkProduct_FK FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID),
    CONSTRAINT WorkEmployee_FK FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID)
);

-- Create FEEDBACK Table
CREATE TABLE Feedback_T (
    FeedbackID NUMERIC(11,0) NOT NULL,
    OrderPurchaseID NUMERIC(11,0) NOT NULL,
    ProductID NUMERIC(11,0) NOT NULL,
    CustomerID NUMERIC(11,0) NOT NULL,
    EmployeeID NUMERIC(11,0),
    FeedbackDate DATE NOT NULL,
    FeedbackDescription NVARCHAR(2000),
    ProductRating DECIMAL(2,1) CHECK (ProductRating >= 1 AND ProductRating <= 5),
    AgentNotes NVARCHAR(2000),  
    ResolutionStatus NVARCHAR(50) CHECK (ResolutionStatus IN ('resolved', 'pending')),  
    HandledByDate DATETIME,
    CONSTRAINT FeedbackHandlingDuration CHECK (
        HandledByDate >= FeedbackDate AND
        HandledByDate <= DATEADD(month, 1, FeedbackDate)
    ), 
    CONSTRAINT Feedback_PK PRIMARY KEY (FeedbackID),
    CONSTRAINT Feedback_FK1 FOREIGN KEY (OrderPurchaseID) REFERENCES OrderPurchase_T(OrderPurchaseID),
    CONSTRAINT Feedback_FK2 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID),
    CONSTRAINT Feedback_FK3 FOREIGN KEY (CustomerID) REFERENCES Customer_T(CustomerID),
    CONSTRAINT Feedback_FK4 FOREIGN KEY (EmployeeID) REFERENCES Employee_T(EmployeeID)
);

-- Create Inventory Table 
CREATE TABLE Inventory_T (
    InventoryID NUMERIC(11,0) NOT NULL,
    ProductID NUMERIC(11,0) NOT NULL,
    UnitsInStock INT CHECK (UnitsInStock >= 0), 
    OverallInventoryStatus NVARCHAR(50) CHECK (OverallInventoryStatus IN ('Low', 'Optimal', 'Overstocked')),
    LastUpdated DATETIME,
    StorageRequirements NVARCHAR(300), 
    CONSTRAINT Inventory_PK PRIMARY KEY (InventoryID),
    CONSTRAINT Inventory_FK1 FOREIGN KEY (ProductID) REFERENCES Product_T(ProductID)
);

-- Create INVENTORY SUPPLY Table 
CREATE TABLE InventorySupply_T (
    InventoryID NUMERIC(11,0) NOT NULL,
    SupplierID NUMERIC(11,0) NOT NULL,
    DeliveryDate DATE NOT NULL,
    BatchNumber VARCHAR(100) CHECK (BatchNumber LIKE 'Batch-%'), 
    RiskManagementInstructions NVARCHAR(1000),
    CONSTRAINT InventorySupply_PK PRIMARY KEY (InventoryID, SupplierID, DeliveryDate),
    CONSTRAINT InventorySupply_FK1 FOREIGN KEY (InventoryID) REFERENCES Inventory_T(InventoryID),
    CONSTRAINT InventorySupply_FK2 FOREIGN KEY (SupplierID) REFERENCES Supplier_T(SupplierID)
);

-- Associative Entities: FEEDBACK, ORDER-PURCHASE LINE, WORK, COLLABORATE, INVENTORY SUPPLY 
-- Regular Entities: CUSTOMER, EMPLOYEE, SUPPLIER, ORDER-PURCHASE, INVENORY 
-- Sub-type Entities: SALES STAFF, MANAGER, CUSTOMER SERVICE AGENT, CREATIVE STAFF, ONLINE CUSTOMER, IN-STORE CUSTOMER, LICENSED PRODUCT, COLLABORATIVE PRODUCT, SELF-DESIGNED PRODUCT

-- Insert into SALES STAFF Table
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (1, '2023-01-15', 'Advanced Sales Techniques', 'Jaipur Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (2, '2023-02-20', 'Customer Relationship Management', 'New Delhi Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (3, '2023-03-05', 'Product Knowledge Workshop', 'New Delhi Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (4, '2023-01-04', 'Negotiation Skills', 'Jaipur Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (5, '2024-02-10', 'Digital Sales Strategies', 'Bombay Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (6, '2023-04-15', 'Sales Analytics', 'Bombay Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (7, '2023-03-22', 'Leadership in Sales', 'Bombay Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (8, '2024-05-01', 'Cross-selling Skills', 'Pune Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (9, '2023-05-20', 'Sales Force Automation', 'Jaipur Branch'); 
INSERT INTO SalesStaff_T (EmployeeID, SalesTrainingCompletionDate, SalesTrainingName, SalesStaffAssignedLocation) 
VALUES (10, '2021-06-10', 'Client Engagement Tactics', 'New Delhi Branch'); 

-- Insert into MANAGER Table
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (12, 500, 'Oversee regional sales'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (14, 501, 'Manage product development projects'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (16, 502, 'Lead marketing campaigns'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (18, 503, 'Supervise manufacturing processes'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (20, 504, 'Control supply chain logistics'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (22, 505, 'Handle customer service operations'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (24, 506, 'Direct software development teams'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (26, 507, 'Oversee financial planning'); 
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks) 
VALUES (28, 508, 'Manage corporate partnerships');
INSERT INTO Manager_T (EmployeeID, HigherLevelManagerID, OperationalTasks)  
VALUES (30, 509, 'Lead HR initiatives'); 

-- Insert into CUSTOMER SERIVCE AGENT Table
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (42, 30); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (45, 4); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (50, 90); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (43, 14); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (46, 18); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (53, 30); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (54, 69); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (55, 39); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (49, 2); 
INSERT INTO CustomerServiceAgent_T (EmployeeID, CustomerInquiryCount) 
VALUES (44, 98);

-- Insert into CREATIVE STAFF Table
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(90, 'Garment Construction', 5); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(91, 'Embroidery', 7); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(92, 'Knitwear Design', 4); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(93, 'Oxidized Jewlery Design', 6); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(94, 'Sustainable Fashion', 8); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(95, 'Bespoke Tailoring', 5); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(96, 'Indian Children Clothing', 3); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(97, 'Fashion Design', 9); 
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(98, 'Embroidery', 7);
INSERT INTO CreativeStaff_T (EmployeeID, SpecializationArea, YearsofExp) VALUES
(99, 'Embroidery', 10); 

-- Insert into ONLINE CUSTOMER Table
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(101, '2023-01-10', 'Credit Card', 'Purchased Laptop on 2023-01-10, Purchased Mouse on 2023-01-15', 'Visited Laptop Page, Visited Accessories Page', 'User_1Aa-123', 'Secure!991'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(102, '2023-01-20', 'PayPal', 'Purchased Smartphone on 2023-01-20, Purchased Case on 2023-01-22', 'Visited Smartphone Page, Visited Checkout', 'Alpha_2Bb-234', 'Welcome@123'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(103, '2023-02-01', 'Debit Card', 'Purchased Tablet on 2023-02-01', 'Visited Tablet Page, Visited Offers Page', 'Gamma_3Cc-345', 'Hello#321'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(104, '2023-02-10', 'Credit Card', 'Purchased Headphones on 2023-02-10', 'Visited Electronics Page, Visited Home Page', 'Delta_4Dd-456', 'Start123$'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(105, '2023-02-15', 'Credit Card', 'Purchased Keyboard on 2023-02-15, Purchased Mouse Pad on 2023-02-17', 'Visited PC Accessories Page, Visited Support Page', 'Echo_5Ee-567', 'Pass!word56'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(106, '2023-02-20', 'PayPal', 'Purchased Camera on 2023-02-20', 'Visited Camera Page, Visited Gallery Page', 'Foxt_6Ff-678', 'What*90'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(107, '2023-03-01', 'Debit Card', 'Purchased Printer on 2023-03-01, Purchased Ink on 2023-03-03', 'Visited Printer Page, Visited Deals Page', 'Golf_7Gg-789', '1234!Abcd'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(108, '2023-03-10', 'Credit Card', 'Purchased Monitor on 2023-03-10', 'Visited Monitor Page, Visited FAQ Page', 'Hotel_8Hh-890', 'Secure*88Aa'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(109, '2023-03-15', 'PayPal', 'Purchased Speakers on 2023-03-15', 'Visited Audio Equipment Page, Visited Reviews Page', 'India_9Ii-901', 'Pass999!@#'); 
INSERT INTO OnlineCustomer_T (CustomerID, AccountCreationDate, OnlinePaymentPreference, OnlineShoppingHistory, OnlineBrowsingHistory, OnlineAccountUsername, OnlineAccountPassword) VALUES
(110, '2023-03-20', 'Credit Card', 'Purchased External Hard Drive on 2023-03-20', 'Visited Storage Solutions Page, Visited Checkout', 'Julie_0Jj-012', 'Qwerty@123');

-- Insert into IN-STORE CUSTOMER Table
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(111, '123 MG Road, Delhi, Delhi, 110001, India', 12, 'Sarees, Kurtas, Lehengas'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(112, '234 Laxmi Road, Pune, Maharashtra, 411030, India', 8, 'Churidars, Dupattas'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(113, '345 Commercial St, Bangalore, Karnataka, 560001, India', 5, 'Sherwanis, Dhotis'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(114, '456 Park Street, Kolkata, West Bengal, 700016, India', 20, 'Panjabis, Shawls'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(115, '890 S.G. Highway, Ahmedabad, Gujarat, 380054, India', 14, 'Kediyu, Gharchola'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(116, '991 Mall Road, Amritsar, Punjab, 143001, India', 10, 'Phulkari, Patiala Salwars'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(117, '102 Bapu Bazar, Udaipur, Rajasthan, 313001, India', 18, 'Leheriya Saree, Jodhpuri Suits');
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(118, '102 Bapu Bazar, Udaipur, Rajasthan, 313001, India', 18, 'Jodhpuri Suits');
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(119, '678 MI Road, Jaipur, Rajasthan, 302001, India', 9, 'Bandhani dresses, Angrakha'); 
INSERT INTO InStoreCustomer_T (CustomerID, PreferredBoutique, InStoreVisitFrequency, InStorePurchaseHistory) VALUES
(120, '890 S.G. Highway, Ahmedabad, Gujarat, 380054, India', 14, 'Kediyu, Gharchola'); 

-- Insert into LICENSED PRODUCT Table
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (101, 'Ethnic Styles Ltd.', 'Exclusive rights for saree designs', 5.0);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (102, 'Modern Threads Pvt.', 'Limited rights for modern Kurtas', 4.5);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (103, 'Heritage Wears Co.', 'Regional rights for Rajasthani attire', 4.0);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (104, 'Punjabi Fabrics Inc.', 'Exclusive rights for Punjabi suits', 3.5);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (105, 'South Silks LLC', 'Rights to produce South Indian silk sarees', 4.8);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (106, 'Kolkata Cottons', 'Rights for Bengali cotton sarees', 3.0);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (107, 'Gujarat Garments', 'Exclusive rights for Gujarati Garba costumes', 6.0);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (108, 'Royal Rajasthan Textiles', 'Rights for Jodhpuri suits and Rajputi poshaks', 5.5);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (109, 'Deccan Handlooms', 'Exclusive rights for Hyderabadi Khada Dupatta sets', 4.2);
INSERT INTO LicensedProduct_T (ProductID, LicenseHolder, LicenseTerms, RateOfRoyalty) 
VALUES (110, 'Mumbai Fashion House', 'Limited rights for Bollywood inspired clothing', 5.1);

-- Insert into COLLABORATIVE PRODUCT Table 
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(111, '2023-01-01', DATEADD(month, 2, '2023-01-01'), 'Saree Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(112, '2023-02-01', DATEADD(month, 2, '2023-02-01'), 'Kurta Creations');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(113, '2023-03-01', DATEADD(month, 2, '2023-03-01'), 'Lehenga Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(114, '2023-04-01', DATEADD(month, 2, '2023-04-01'), 'Sherwani Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(115, '2023-05-01', DATEADD(month, 2, '2023-05-01'), 'Dupatta Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(116, '2023-06-01', DATEADD(month, 2, '2023-06-01'), 'Churidar Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(117, '2023-07-01', DATEADD(month, 2, '2023-07-01'), 'Ghagra Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(118, '2023-08-01', DATEADD(month, 2, '2023-08-01'), 'Patiala Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(119, '2023-09-01', DATEADD(month, 2, '2023-09-01'), 'Anarkali Design Team');
INSERT INTO CollaborativeProduct_T (ProductID, CollaborationStartDate, CollaborationEndDate, CollaborativeProductTeam) VALUES 
(120, '2023-10-01', DATEADD(month, 2, '2023-10-01'), 'Bandhani Design Team');

-- Insert into SELF-DESIGNED PRODUCT Table 
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(111, 'Innovative Weaves', 'Handwoven techniques combining traditional and modern styles');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(112, 'Modern Saree Makers', 'Automated looms for precision and efficiency in saree production');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(113, 'Kurta Couture', 'Eco-friendly dyeing and cotton weaving techniques');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(114, 'Ethnic Team', 'Blend of silk threading with zari embroidery for festive wear');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(115, 'Casual Crafters', 'Integration of digital printing for casual kurtas');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(116, 'Lehenga Luxe', 'Detailed hand embroidery and custom beadwork');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(117, 'Sherwani Styles', 'Use of brocade fabrics and traditional tailoring techniques');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(118, 'Dupatta Designs', 'Innovative dye techniques and hand-painting on chiffon');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(119, 'Churidar Team', 'Sustainable manufacturing processes with organic materials');
INSERT INTO SelfDesignedProduct_T (ProductID, DesignTeamName, ProductionMethod) VALUES 
(120, 'Patiala Pioneers', 'Revival of old Punjabi designs with modern textile technology');

-- Insert into FEEDBACK Table 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (1, 1001, 101, 101, 1, '2023-01-01', 'Excellent product quality.', 5, 'Customer very satisfied.', 'resolved', '2023-01-15'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (2, 1002, 102, 102, 2, '2023-01-05', 'Quick delivery.', 5, 'Delivery team commended.', 'resolved', '2023-01-20'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (3, 1003, 103, 103, 3, '2023-01-10', 'Great customer service.', 4, 'Handled swiftly.', 'resolved', '2023-01-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (4, 1004, 104, 104, 4, '2023-01-15', 'Product not as described.', 2, 'Refund issued.', 'resolved', '2023-01-30'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (5, 1005, 105, 105, 5, '2023-01-20', 'Package was damaged.', 1, 'Replacement sent.', 'resolved', '2023-02-01'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (6, 1006, 106, 106, 6, '2023-01-25', 'Great value for money.', 5, 'Positive feedback.', 'resolved', '2023-02-10'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (7, 1007, 107, 107, 7, '2023-01-30', 'Customer service could be better.', 3, 'Follow-up call made.', 'resolved', '2023-02-15'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (8, 1008, 108, 108, 8, '2023-02-05', 'Happy with the purchase.', 4, 'Customer thanked.', 'resolved', '2023-02-20'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (9, 1009, 109, 109, 9, '2023-02-10', 'Product arrived late.', 2, 'Apology issued.', 'resolved', '2023-02-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (10, 1010, 110, 110, 10, '2023-02-15', 'Excellent packaging.', 5, 'Packaging team commended.', 'resolved', '2023-02-28'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (11, 1011, 111, 111, 12, '2023-02-20', 'Not satisfied with the product.', 1, 'Issue unresolved.', 'pending', '2023-02-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (12, 1012, 112, 112, 14, '2023-02-25', 'Very user-friendly.', 4, 'Positive feedback.', 'resolved', '2023-03-05'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (13, 1013, 113, 113, 16, '2023-03-01', 'Product is too expensive.', 2, 'Price concerns noted.', 'resolved', '2023-03-10'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (14, 1014, 114, 114, 18, '2023-03-05', 'Good product for the price.', 4, 'Customer satisfied.', 'resolved', '2023-03-15'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (15, 1015, 115, 115, 20, '2023-03-10', 'Average quality.', 3, 'Noted for improvement.', 'resolved', '2023-03-20'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (16, 1016, 116, 116, 22, '2023-03-15', 'Excellent customer service.', 5, 'Employee praised.', 'resolved', '2023-03-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (17, 1017, 117, 117, 24, '2023-03-20', 'Product needs improvement.', 2, 'Suggestions noted.', 'resolved', '2023-03-30'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (18, 1018, 118, 118, 26, '2023-03-25', 'Fantastic experience.', 5, 'Customer thanked.', 'resolved', '2023-04-05'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (19, 1019, 119, 119, 28, '2023-03-30', 'Product not working properly.', 1, 'Issue being investigated.', 'pending', '2023-04-10'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (20, 1020, 120, 120, 30, '2023-04-01', 'Great for the price.', 4, 'Positive feedback.', 'resolved', '2023-04-10'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (21, 1021, 121, 121, 42, '2023-04-05', 'Satisfied with purchase.', 4, 'Customer satisfied.', 'resolved', '2023-04-15'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (22, 1022, 122, 122, 45, '2023-04-10', 'Product arrived early.', 5, 'Commended delivery team.', 'resolved', '2023-04-20'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (23, 1023, 123, 123, 50, '2023-04-15', 'Product was defective.', 1, 'Replacement issued.', 'resolved', '2023-04-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (24, 1024, 124, 124, 43, '2023-04-20', 'Packaging could be better.', 3, 'Feedback noted.', 'resolved', '2023-04-30'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (25, 1025, 125, 125, 46, '2023-04-25', 'Very good service.', 5, 'Commended service team.', 'resolved', '2023-05-05'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (26, 1026, 126, 126, 53, '2023-04-30', 'Product as described.', 4, 'Customer happy.', 'resolved', '2023-05-10'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (27, 1027, 127, 127, 54, '2023-05-05', 'Product did not meet expectations.', 2, 'Noted for improvement.', 'resolved', '2023-05-15'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (28, 1028, 128, 128, 55, '2023-05-10', 'Very satisfied.', 5, 'Customer delighted.', 'resolved', '2023-05-20'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (29, 1029, 129, 129, 49, '2023-05-15', 'Good product overall.', 4, 'Positive feedback.', 'resolved', '2023-05-25'); 
INSERT INTO Feedback_T (FeedbackID, OrderPurchaseID, ProductID, CustomerID, EmployeeID, FeedbackDate, FeedbackDescription, ProductRating, AgentNotes, ResolutionStatus, HandledByDate) 
VALUES (30, 1030, 130, 130, 44, '2023-05-20', 'Not happy with the service.', 2, 'Service needs improvement.', 'resolved', '2023-05-30');

-- Insert into ORDER-PURCHASE LINE Table
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (1, 1001, 101, 2, 500.00, 1000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (2, 1001, 102, 1, 1500.00, 1500.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (3, 1002, 103, 5, 200.00, 1000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (4, 1002, 104, 3, 750.00, 2250.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (5, 1003, 105, 10, 100.00, 1000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (6, 1003, 106, 7, 300.00, 2100.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (7, 1004, 107, 4, 400.00, 1600.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (8, 1004, 108, 6, 500.00, 3000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (9, 1005, 109, 8, 250.00, 2000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (10, 1005, 110, 3, 600.00, 1800.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (11, 1006, 111, 5, 450.00, 2250.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (12, 1006, 112, 7, 550.00, 3850.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (13, 1007, 113, 6, 350.00, 2100.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (14, 1007, 114, 4, 700.00, 2800.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (15, 1008, 115, 2, 900.00, 1800.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (16, 1008, 116, 3, 800.00, 2400.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (17, 1009, 117, 1, 1500.00, 1500.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (18, 1009, 118, 5, 200.00, 1000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (19, 1010, 119, 2, 1000.00, 2000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (20, 1010, 120, 4, 750.00, 3000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (21, 1011, 121, 6, 500.00, 3000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (22, 1011, 122, 3, 800.00, 2400.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (23, 1012, 123, 7, 250.00, 1750.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (24, 1012, 124, 4, 650.00, 2600.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (25, 1013, 125, 5, 400.00, 2000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (26, 1013, 126, 6, 600.00, 3600.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (27, 1014, 127, 3, 850.00, 2550.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (28, 1014, 128, 4, 750.00, 3000.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (29, 1015, 129, 2, 950.00, 1900.00); 
INSERT INTO OrderPurchaseLine_T (OrderPurchaseLineID, OrderPurchaseID, ProductID, OrderPurchaseLineProductUnit, OrderPurchaseLineUnitCost, OrderPurchaseLineTotalCost) 
VALUES (30, 1015, 130, 5, 300.00, 1500.00);

-- Insert into WORK Table 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (1, 101, 'Designer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (2, 102, 'Tailor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (3, 103, 'Pattern Maker'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (4, 104, 'Embroiderer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (5, 105, 'Quality Control'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (6, 106, 'Production Supervisor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (7, 107, 'Designer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (8, 108, 'Tailor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (9, 109, 'Pattern Maker'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (10, 110, 'Embroiderer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (11, 111, 'Quality Control'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (12, 112, 'Production Supervisor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (13, 113, 'Designer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (14, 114, 'Tailor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (15, 115, 'Pattern Maker'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (16, 116, 'Embroiderer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (17, 117, 'Quality Control'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (18, 118, 'Production Supervisor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (19, 119, 'Designer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (20, 101, 'Tailor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (21, 102, 'Pattern Maker'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (22, 103, 'Embroiderer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (23, 104, 'Quality Control'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (24, 105, 'Production Supervisor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (25, 106, 'Designer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (26, 107, 'Tailor'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (27, 108, 'Pattern Maker'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (28, 109, 'Embroiderer'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (29, 110, 'Quality Control'); 
INSERT INTO Work_T (EmployeeID, ProductID, Role) 
VALUES (30, 111, 'Production Supervisor');

-- Insert into COLLABORATE Table 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (1, 101); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (2, 102); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (3, 103); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (4, 104); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (5, 105); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (6, 106); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (7, 107); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (8, 108); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (9, 109); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (10, 110); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (11, 111); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (12, 112); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (13, 113); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (14, 114); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (15, 115); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (16, 101); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (17, 102); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (18, 103); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (19, 104); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (20, 105); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (21, 106); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (22, 107); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (23, 108); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (24, 109); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (25, 110); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (26, 111); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (27, 111); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (28,105); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (29,106); 
INSERT INTO Collaborate_T (EmployeeID, ProductID) 
VALUES (30, 107);

-- Insert into INVENTORY SUPPLY Table 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (1, 301, '2023-01-01', 'Batch-001', 'Handle with care; keep dry.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (2, 302, '2023-01-02', 'Batch-002', 'Store in cool place; avoid direct sunlight.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (3, 303, '2023-01-03', 'Batch-003', 'Fragile; handle with care.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (4, 304, '2023-01-04', 'Batch-004', 'Keep away from moisture.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (5, 305, '2023-01-05', 'Batch-005', 'Do not stack.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (6, 306, '2023-01-06', 'Batch-006', 'Store at room temperature.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (7, 307, '2023-01-07', 'Batch-007', 'Keep in dry area; avoid humidity.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (8, 308, '2023-01-08', 'Batch-008', 'Handle with care; keep away from heat.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (9, 309, '2023-01-09', 'Batch-009', 'Fragile; store on top shelves.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (10, 310, '2023-01-10', 'Batch-010', 'Store in a well-ventilated area.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (11, 301, '2023-01-11', 'Batch-011', 'Keep dry; avoid stacking.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (12, 302, '2023-01-12', 'Batch-012', 'Store upright; handle with care.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (13, 303, '2023-01-13', 'Batch-013', 'Keep away from flammable materials.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (14, 304, '2023-01-14', 'Batch-014', 'Store in a cool, dry place.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (15, 305, '2023-01-15', 'Batch-015', 'Do not stack; handle with care.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (16, 306, '2023-01-16', 'Batch-016', 'Store at 20°C; avoid direct sunlight.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (17, 307, '2023-01-17', 'Batch-017', 'Keep dry; handle with care.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (18, 308, '2023-01-18', 'Batch-018', 'Store in original packaging.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (19, 309, '2023-01-19', 'Batch-019', 'Handle with gloves; keep dry.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (20, 310, '2023-01-20', 'Batch-020', 'Keep away from children; store securely.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (21, 301, '2023-01-21', 'Batch-021', 'Store upright; avoid shaking.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (22, 302, '2023-01-22', 'Batch-022', 'Store in a dry, cool place.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (23, 303, '2023-01-23', 'Batch-023', 'Handle with care; keep away from heat sources.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (24, 304, '2023-01-24', 'Batch-024', 'Keep dry; store on top shelves.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (25, 305, '2023-01-25', 'Batch-025', 'Store in a well-ventilated area.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (26, 306, '2023-01-26', 'Batch-026', 'Keep away from moisture; store upright.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (27, 307, '2023-01-27', 'Batch-027', 'Handle with care; avoid stacking.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (28, 308, '2023-01-28', 'Batch-028', 'Store in original packaging; handle with care.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (29, 309, '2023-01-29', 'Batch-029', 'Keep dry; store securely.'); 
INSERT INTO InventorySupply_T (InventoryID, SupplierID, DeliveryDate, BatchNumber, RiskManagementInstructions) 
VALUES (30, 310, '2023-01-30', 'Batch-030', 'Handle with gloves; keep away from heat sources.');

-- Insert into CUSTOMER Table
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (101, 'Pari Sharma', '123 MG Road, Delhi', '+91-9876543210', 'pari.sharma@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (102, 'Amit Kumar', '456 Park Street, Kolkata', '+91-9876543211', 'amit.kumar@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (103, 'Meena Gupta', '789 Laxmi Road, Pune', '+91-9876543212', 'meena.gupta@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (104, 'Ravi Singh', '101 Bapu Bazar, Udaipur', '+91-9876543213', 'ravi.singh@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (105, 'Anjali Verma', '234 Mall Road, Amritsar', '+91-9876543214', 'anjali.verma@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (106, 'Vikram Mehta', '567 SG Highway, Ahmedabad', '+91-9876543215', 'vikram.mehta@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (107, 'Priya Nair', '890 Commercial St, Bangalore', '+91-9876543216', 'priya.nair@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (108, 'Rajesh Patel', '345 Churchgate, Mumbai', '+91-9876543217', 'rajesh.patel@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (109, 'Sita Reddy', '678 Marina Beach, Chennai', '+91-9876543218', 'sita.reddy@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (110, 'Anand Joshi', '890 Residency Road, Hyderabad', '+91-9876543219', 'anand.joshi@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (111, 'Kiran Rao', '102 MG Road, Delhi', '+91-9876543220', 'kiran.rao@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (112, 'Neha Malhotra', '345 Park Street, Kolkata', '+91-9876543221', 'neha.malhotra@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (113, 'Suresh Chandra', '678 Laxmi Road, Pune', '+91-9876543222', 'suresh.chandra@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (114, 'Sunita Jain', '890 Bapu Bazar, Udaipur', '+91-9876543223', 'sunita.jain@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (115, 'Manoj Kumar', '123 Mall Road, Amritsar', '+91-9876543224', 'manoj.kumar@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (116, 'Divya Singh', '456 SG Highway, Ahmedabad', '+91-9876543225', 'divya.singh@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (117, 'Rahul Verma', '789 Commercial St, Bangalore', '+91-9876543226', 'rahul.verma@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (118, 'Lata Patel', '101 Churchgate, Mumbai', '+91-9876543227', 'lata.patel@example.com', 'I'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (119, 'Vijay Sharma', '234 Marina Beach, Chennai', '+91-9876543228', 'vijay.sharma@example.com', 'O'); 
INSERT INTO Customer_T (CustomerID, CustomerName, CustomerAddress, CustomerPhoneNumber, CustomerEmailAddress, CustomerType) 
VALUES (120, 'Nisha Gupta', '567 Residency Road, Hyderabad', '+91-9876543229', 'nisha.gupta@example.com', 'I');

-- Insert into EMPLOYEE Table
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (1, 'Rohit Sharma', '2022-01-15', 50000.00, 'Sales Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (2, 'Meera Singh', '2021-05-20', 75000.00, 'Manager'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (3, 'Anil Kumar', '2020-11-30', 45000.00, 'Customer Service Agent'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (4, 'Kavita Nair', '2019-03-25', 60000.00, 'Creative Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (5, 'Rakesh Verma', '2018-07-19', 52000.00, 'Sales Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (6, 'Deepa Mehta', '2021-02-14', 78000.00, 'Manager'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (7, 'Manish Joshi', '2020-06-23', 46000.00, 'Customer Service Agent'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (8, 'Shweta Kapoor', '2019-10-11', 61000.00, 'Creative Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (9, 'Gaurav Reddy', '2018-01-09', 53000.00, 'Sales Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (10, 'Rina Patel', '2017-12-01', 79000.00, 'Manager'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (11, 'Sanjay Rao', '2016-05-15', 47000.00, 'Customer Service Agent'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (12, 'Nisha Mehta', '2015-08-20', 62000.00, 'Creative Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (13, 'Rajesh Singh', '2022-04-01', 54000.00, 'Sales Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (14, 'Sunil Jain', '2021-09-15', 80000.00, 'Manager'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (15, 'Anita Kumar', '2020-12-01', 48000.00, 'Customer Service Agent'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (16, 'Divya Reddy', '2019-02-15', 63000.00, 'Creative Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (17, 'Rahul Sharma', '2018-06-19', 55000.00, 'Sales Staff'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (18, 'Lata Patel', '2017-10-25', 81000.00, 'Manager'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (19, 'Vijay Sharma', '2016-03-17', 49000.00, 'Customer Service Agent'); 
INSERT INTO Employee_T (EmployeeID, EmployeeName, EmployeeHireDate, EmployeeSalary, EmployeeRole) 
VALUES (20, 'Nisha Gupta', '2015-07-05', 64000.00, 'Creative Staff');

-- Insert into PRODUCT Table 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (501, 'Traditional Saree', 'A beautiful traditional saree with intricate embroidery.', 1500.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (502, 'Modern Kurta', 'A stylish kurta perfect for casual and formal occasions.', 1200.00, 'C'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (503, 'Rajasthani Lehenga', 'An exquisite lehenga with traditional Rajasthani designs.', 2500.00, 'L'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (504, 'Punjabi Suit', 'A vibrant Punjabi suit with beautiful Phulkari embroidery.', 2000.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (505, 'South Indian Silk Saree', 'A luxurious silk saree from South India.', 3000.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (506, 'Bengali Cotton Saree', 'A comfortable and elegant cotton saree from Bengal.', 1800.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (507, 'Gujarati Garba Costume', 'A colorful and traditional Garba costume from Gujarat.', 2200.00, 'C'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (508, 'Jodhpuri Suit', 'A royal Jodhpuri suit with intricate designs.', 2700.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (509, 'Hyderabadi Khada Dupatta Set', 'A traditional Khada Dupatta set from Hyderabad.', 2400.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (510, 'Bollywood Inspired Dress', 'A glamorous dress inspired by Bollywood fashion.', 2600.00, 'L'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (511, 'Casual Kurta', 'A comfortable casual kurta for daily wear.', 1000.00, 'C'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (512, 'Formal Sherwani', 'A sophisticated sherwani for formal occasions.', 3500.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (513, 'Designer Dupatta', 'An elegant dupatta with detailed embroidery.', 900.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (514, 'Traditional Churidar', 'A traditional churidar with comfortable fit.', 1100.00, 'C'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (515, 'Festive Ghagra', 'A festive ghagra with vibrant colors and designs.', 2300.00, 'L'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (516, 'Classic Patiala Suit', 'A classic Patiala suit perfect for festive occasions.', 2100.00, 'S'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (517, 'Elegant Anarkali', 'An elegant Anarkali with flowing design.', 2900.00, 'L'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (518, 'Bandhani Dress', 'A traditional Bandhani dress with unique patterns.', 1600.00, 'L'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (519, 'Oxidized Jewelry Set', 'A beautiful oxidized jewelry set.', 800.00, 'C'); 
INSERT INTO Product_T (ProductID, ProductName, ProductDescription, ProductPrice, ProductCategory) 
VALUES (520, 'Ethnic Children Clothing', 'Ethnic clothing for children with vibrant designs.', 1300.00, 'C');

-- Insert into SUPPLIER Table
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (301, 'Ethnic Styles Ltd.', 'info@ethnicstyles.com', '+91-9876543210', '123 Silk Street, Delhi, 110001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (302, 'Modern Threads Pvt.', 'contact@modernthreads.com', '+91-9876543211', '456 Cotton Avenue, Mumbai, 400020, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (303, 'Heritage Wears Co.', 'sales@heritagewears.co', '+91-9876543212', '789 Tradition Lane, Kolkata, 700016, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (304, 'Punjabi Fabrics Inc.', 'support@punjabifabrics.com', '+91-9876543213', '101 Phulkari Blvd, Amritsar, 143001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (305, 'South Silks LLC', 'service@southsilks.com', '+91-9876543214', '234 Silk Road, Chennai, 600004, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (306, 'Kolkata Cottons', 'info@kolkatacottons.com', '+91-9876543215', '345 Cotton St, Kolkata, 700016, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (307, 'Gujarat Garments', 'contact@gujaratgarments.com', '+91-9876543216', '456 Garba Lane, Ahmedabad, 380054, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (308, 'Royal Rajasthan Textiles', 'sales@royalrajasthan.com', '+91-9876543217', '789 Royal Street, Jaipur, 302001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (309, 'Deccan Handlooms', 'support@deccanhandlooms.com', '+91-9876543218', '101 Handloom Road, Hyderabad, 500001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (310, 'Mumbai Fashion House', 'service@mumbaifashion.com', '+91-9876543219', '234 Fashion Blvd, Mumbai, 400020, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (311, 'Vintage Textiles', 'info@vintagetextiles.com', '+91-9876543220', '345 Vintage Lane, Delhi, 110001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (312, 'Elegant Fabrics', 'contact@elegantfabrics.com', '+91-9876543221', '456 Elegant St, Bangalore, 560001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (313, 'Regal Attire', 'sales@regalattire.com', '+91-9876543222', '789 Regal Road, Delhi, 110001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (314, 'Classic Looms', 'support@classiclooms.com', '+91-9876543223', '101 Looms Blvd, Chennai, 600004, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (315, 'Luxury Threads', 'service@luxurythreads.co', '+91-9876543224', '234 Luxury St, Mumbai, 400020, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (316, 'Exclusive Fabrics', 'info@exclusivefabrics.in', '+91-9876543225', '345 Exclusive Lane, Kolkata, 700016, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (317, 'Majestic Weaves', 'contact@majesticweaves.com', '+91-9876543226', '456 Majestic St, Hyderabad, 500001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (318, 'Premium Textiles', 'sales@premiumtextiles.com', '+91-9876543227', '789 Premium Road, Bangalore, 560001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (319, 'Silk & Cotton Co.', 'support@silkcotton.com', '+91-9876543228', '101 Silk Blvd, Ahmedabad, 380054, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (320, 'Handcrafted Fabrics', 'service@handcraftedfabrics.in', '+91-9876543229', '234 Handcrafted St, Amritsar, 143001, India'); 
INSERT INTO Supplier_T (SupplierID, SupplierCompName, SupplierEmailAdress, SupplierPhoneNumber, SupplierAddress) 
VALUES (321, 'Ethnic Creations', 'info@ethniccreations.com', '+91-9876543230', '345 Ethnic Lane, Jaipur, 302001, India');

-- Insert into ORDER-PURCHASE Table 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1001, 101, '2023-01-01 10:00:00', 3000.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1002, 102, '2023-01-05 14:30:00', 4500.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1003, 103, '2023-01-10 09:15:00', 2500.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1004, 104, '2023-01-15 11:45:00', 3200.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1005, 105, '2023-01-20 16:30:00', 2700.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1006, 106, '2023-01-25 12:00:00', 1500.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1007, 107, '2023-01-30 14:00:00', 4100.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1008, 108, '2023-02-01 10:30:00', 3600.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1009, 109, '2023-02-05 15:45:00', 2900.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1010, 110, '2023-02-10 13:00:00', 4000.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1011, 111, '2023-02-15 09:30:00', 2800.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1012, 112, '2023-02-20 11:45:00', 3500.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1013, 113, '2023-02-25 14:15:00', 2600.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1014, 114, '2023-03-01 16:30:00', 2200.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1015, 115, '2023-03-05 10:45:00', 3100.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1016, 116, '2023-03-10 13:15:00', 3300.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1017, 117, '2023-03-15 15:00:00', 2700.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1018, 118, '2023-03-20 11:30:00', 3400.00, 'Pending'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1019, 119, '2023-03-25 14:45:00', 3900.00, 'Completed'); 
INSERT INTO OrderPurchase_T (OrderPurchaseID, CustomerID, OrderPurchaseDate, OrderPurchaseTotalCost, OrderPurchaseStatus) 
VALUES (1020, 120, '2023-03-30 10:15:00', 4200.00, 'Pending');

-- Insert into INVENTORY Table 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (1, 1, 50, 'Optimal', '2023-01-10 10:00:00', 'Store in a dry place, avoid direct sunlight'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (2, 2, 20, 'Low', '2023-01-15 14:30:00', 'Store in a cool, dry place'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (3, 3, 70, 'Optimal', '2023-01-20 09:15:00', 'Store in a dry place, use moth repellents'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (4, 4, 30, 'Low', '2023-01-25 11:45:00', 'Keep away from moisture'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (5, 5, 100, 'Overstocked', '2023-01-30 16:30:00', 'Store in a cool, dry place, avoid humidity'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (6, 6, 10, 'Low', '2023-02-05 12:00:00', 'Store in a dry place, use desiccants'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (7, 7, 80, 'Optimal', '2023-02-10 14:00:00', 'Store in a cool, dry place, avoid direct sunlight'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (8, 8, 60, 'Optimal', '2023-02-15 10:30:00', 'Keep away from moisture and dust'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (9, 9, 40, 'Low', '2023-02-20 15:45:00', 'Store in a dry place, use moth repellents'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (10, 10, 90, 'Overstocked', '2023-02-25 13:00:00', 'Store in a cool, dry place'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (11, 11, 50, 'Optimal', '2023-03-01 09:30:00', 'Keep away from direct sunlight'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (12, 12, 20, 'Low', '2023-03-05 11:45:00', 'Store in a dry place, avoid humidity'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (13, 13, 70, 'Optimal', '2023-03-10 14:15:00', 'Keep away from moisture and dust'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (14, 14, 30, 'Low', '2023-03-15 16:30:00', 'Store in a cool, dry place'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (15, 15, 100, 'Overstocked', '2023-03-20 10:45:00', 'Store in a dry place, use desiccants'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (16, 16, 10, 'Low', '2023-03-25 13:15:00', 'Keep away from direct sunlight'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (17, 17, 80, 'Optimal', '2023-03-30 15:00:00', 'Store in a cool, dry place, avoid humidity'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (18, 18, 60, 'Optimal', '2023-04-05 11:30:00', 'Store in a dry place, use moth repellents'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (19, 19, 40, 'Low', '2023-04-10 14:45:00', 'Keep away from moisture and dust'); 
INSERT INTO Inventory_T (InventoryID, ProductID, UnitsInStock, OverallInventoryStatus, LastUpdated, StorageRequirements) 
VALUES (20, 20, 90, 'Overstocked', '2023-04-15 10:15:00', 'Store in a cool, dry place');

-- View #1: Inventory Status View
CREATE VIEW InventoryStatus_V AS
SELECT 
    Inventory_T.InventoryID,
    Product_T.ProductName,
    Inventory_T.UnitsInStock,
    Inventory_T.OverallInventoryStatus,
    Inventory_T.LastUpdated,
    Inventory_T.StorageRequirements
FROM 
    Inventory_T
JOIN 
    Product_T ON Inventory_T.ProductID = Product_T.ProductID;

-- Implementation 
SELECT InventoryID, ProductName, UnitsInStock, OverallInventoryStatus 
FROM InventoryStatus_V
WHERE OverallInventoryStatus = 'Low';

-- View #2: Customer Order View 
CREATE VIEW CustomerOrderHistory_V AS
SELECT 
    Customer_T.CustomerID,
    Customer_T.CustomerName,
    OrderPurchase_T.OrderPurchaseID,
    OrderPurchase_T.OrderPurchaseDate,
    OrderPurchase_T.OrderPurchaseTotalCost,
    OrderPurchase_T.OrderPurchaseStatus
FROM 
    Customer_T
JOIN 
    OrderPurchase_T ON Customer_T.CustomerID = OrderPurchase_T.CustomerID;

-- Implementation 
SELECT CustomerID, CustomerName, OrderPurchaseID, OrderPurchaseTotalCost
FROM CustomerOrderHistory_V
WHERE OrderPurchaseStatus = 'Delivered';

-- View #3: Customer Contact Information View 
CREATE VIEW CustomerContact_V AS
SELECT 
    Customer_T.CustomerID,
    Customer_T.CustomerName,
    Customer_T.CustomerPhoneNumber,
    Customer_T.CustomerEmailAddress,
    Customer_T.CustomerAddress
FROM 
    Customer_T;

-- Implementation
SELECT CustomerID, CustomerName, CustomerPhoneNumber, CustomerEmailAddress
FROM CustomerContact_V
WHERE CustomerPhoneNumber LIKE '+91%'; 

