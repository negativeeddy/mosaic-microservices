CREATE TABLE [dbo].[Tiles] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Source]   NVARCHAR (MAX) NOT NULL,
    [SourceId] NVARCHAR (MAX) NOT NULL,
    [Width]    INT            NULL,
    [Height]   INT            NULL,
    [AverageR] TINYINT        NULL,
    [AverageG] TINYINT        NULL,
    [AverageB] TINYINT        NULL,
    [Date]     DATETIME2 (7)  NULL,
    [Aspect]   REAL           NULL
);


