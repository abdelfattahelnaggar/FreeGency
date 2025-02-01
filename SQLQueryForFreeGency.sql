-- Create the FreeGency Database
CREATE DATABASE FreeGency;
GO

-- Use the FreeGency Database
USE FreeGency;
GO

-- Create Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(100) UNIQUE NOT NULL,
    UserPassword NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Role NVARCHAR(50) NOT NULL, -- Client, Team Leader, Team Member
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),
    ProfileImageURL NVARCHAR(255),
    TeamCount INT NOT NULL DEFAULT 0 -- Tracks number of teams joined
);
GO

-- Create Teams Table
CREATE TABLE Teams (
    TeamID INT PRIMARY KEY IDENTITY(1,1),
    TeamName NVARCHAR(100) NOT NULL,
    LeaderID INT NOT NULL,
    TeamCode NVARCHAR(16) UNIQUE NOT NULL, -- 16-character team code
    Description NVARCHAR(255),
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (LeaderID) REFERENCES Users(UserID)
);
GO

-- Create TeamMembers Table
CREATE TABLE TeamMembers (
    TeamID INT NOT NULL,
    UserID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Active', -- Active, Removed, Left
    PRIMARY KEY (TeamID, UserID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- Create Projects Table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Budget DECIMAL(10, 2),
    Status NVARCHAR(50) NOT NULL, -- Open, In Progress, Completed
    TrelloBoardID NVARCHAR(100), -- Trello Board ID for task management
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (ClientID) REFERENCES Users(UserID)
);
GO

-- Create Applications Table
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY IDENTITY(1,1),
    TeamID INT NOT NULL,
    ProjectID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Pending, Accepted, Rejected
    Applied_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);
GO

-- Create JobAnnouncements Table
CREATE TABLE JobAnnouncements (
    JobID INT PRIMARY KEY IDENTITY(1,1),
    TeamID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Posted_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
GO

-- Create JobApplications Table
CREATE TABLE JobApplications (
    JobApplicationID INT PRIMARY KEY IDENTITY(1,1),
    JobID INT NOT NULL,
    UserID INT NOT NULL,
    CV_URL NVARCHAR(255) NOT NULL,
    Applied_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (JobID) REFERENCES JobAnnouncements(JobID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- Create Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    TeamID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Pending, Completed, Failed
    Timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (ClientID) REFERENCES Users(UserID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
GO

-- Create Transactions Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    PaymentID INT NOT NULL,
    Type NVARCHAR(50) NOT NULL, -- Credit, Debit
    Amount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Success, Failed
    Timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID)
);
GO

-- Create Reviews Table
CREATE TABLE Reviews (
    ReviewID INT PRIMARY KEY IDENTITY(1,1),
    ReviewerID INT NOT NULL, -- UserID of the reviewer (Client or Team Leader)
    TeamID INT NOT NULL, -- Team being reviewed
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(255),
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (ReviewerID) REFERENCES Users(UserID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
GO

-- Create Indexes for Faster Queries
CREATE INDEX idx_Users_Email ON Users(Email);
CREATE INDEX idx_Teams_TeamCode ON Teams(TeamCode);
CREATE INDEX idx_Projects_ClientID ON Projects(ClientID);
CREATE INDEX idx_Applications_TeamID ON Applications(TeamID);
CREATE INDEX idx_JobApplications_UserID ON JobApplications(UserID);
CREATE INDEX idx_Payments_ClientID ON Payments(ClientID);
CREATE INDEX idx_Reviews_TeamID ON Reviews(TeamID);
GO

-- Print Success Message
PRINT 'FreeGency database and tables created successfully!';
GO