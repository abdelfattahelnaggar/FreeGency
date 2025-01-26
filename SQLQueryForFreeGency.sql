-- Create the database
CREATE DATABASE FreeGency;
GO

USE FreeGency;
GO

-- 1. Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    UserName NVARCHAR(100) UNIQUE NOT NULL,
    UserPassword NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Role NVARCHAR(50) NOT NULL, -- Client, TeamLeader, TeamMember
    Created_At DATETIME NOT NULL DEFAULT GETDATE(),
    ProfileImageURL NVARCHAR(255),
    isTeamMember BIT NOT NULL DEFAULT 0 -- 0 = Not a team member, 1 = Team member
);
GO

-- 2. Teams Table
CREATE TABLE Teams (
    TeamID INT PRIMARY KEY IDENTITY(1,1),
    TeamName NVARCHAR(100) NOT NULL,
    LeaderID INT NOT NULL,
    TeamCode NVARCHAR(16) UNIQUE NOT NULL, -- 16-character team code
    Description NVARCHAR(255),
    FOREIGN KEY (LeaderID) REFERENCES Users(UserID)
);
GO

-- 3. TeamMembers Table
CREATE TABLE TeamMembers (
    TeamID INT NOT NULL,
    UserID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Active', -- Active, Removed, Left
    PRIMARY KEY (TeamID, UserID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- 4. Projects Table
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Budget DECIMAL(10, 2),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Open', -- Open, In Progress, Completed
    TrelloBoardID NVARCHAR(100), -- Trello Board ID for task management
    FOREIGN KEY (ClientID) REFERENCES Users(UserID)
);
GO

-- 5. Applications Table
CREATE TABLE Applications (
    ApplicationID INT PRIMARY KEY IDENTITY(1,1),
    TeamID INT NOT NULL,
    ProjectID INT NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Accepted, Rejected
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);
GO

-- 6. Tasks Table
CREATE TABLE Tasks (
    TaskID INT PRIMARY KEY IDENTITY(1,1),
    ProjectID INT NOT NULL,
    TaskDescription NVARCHAR(255) NOT NULL,
    DueDate DATETIME NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, In Progress, Completed
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);
GO

-- 7. TaskAssignments Table
CREATE TABLE TaskAssignments (
    TaskAssignmentID INT PRIMARY KEY IDENTITY(1,1),
    TaskID INT NOT NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- 8. Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT NOT NULL,
    TeamID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Completed, Refunded
    Timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (ClientID) REFERENCES Users(UserID),
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID)
);
GO

-- 9. Transactions Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    PaymentID INT NOT NULL,
    Type NVARCHAR(50) NOT NULL, -- Payment, Refund
    Amount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL, -- Success, Failed
    Timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID)
);
GO

-- 10. Reviews Table
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

-- 11. TrelloBoards Table
CREATE TABLE TrelloBoards (
    TrelloBoardID NVARCHAR(100) PRIMARY KEY,
    ProjectID INT NOT NULL,
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);
GO