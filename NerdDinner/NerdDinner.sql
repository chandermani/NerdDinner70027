/****** Object:  UserDefinedFunction [dbo].[DistanceBetween]    Script Date: 02/14/2012 20:34:03 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DistanceBetween]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[DistanceBetween] (@Lat1 as real,
                @Long1 as real, @Lat2 as real, @Long2 as real)
RETURNS real
AS
BEGIN

DECLARE @dLat1InRad as float(53);
SET @dLat1InRad = @Lat1 * (PI()/180.0);
DECLARE @dLong1InRad as float(53);
SET @dLong1InRad = @Long1 * (PI()/180.0);
DECLARE @dLat2InRad as float(53);
SET @dLat2InRad = @Lat2 * (PI()/180.0);
DECLARE @dLong2InRad as float(53);
SET @dLong2InRad = @Long2 * (PI()/180.0);

DECLARE @dLongitude as float(53);
SET @dLongitude = @dLong2InRad - @dLong1InRad;
DECLARE @dLatitude as float(53);
SET @dLatitude = @dLat2InRad - @dLat1InRad;
/* Intermediate result a. */
DECLARE @a as float(53);
SET @a = SQUARE (SIN (@dLatitude / 2.0)) + COS (@dLat1InRad)
                 * COS (@dLat2InRad)
                 * SQUARE(SIN (@dLongitude / 2.0));
/* Intermediate result c (great circle distance in Radians). */
DECLARE @c as real;
SET @c = 2.0 * ATN2 (SQRT (@a), SQRT (1.0 - @a));
DECLARE @kEarthRadius as real;
/* SET kEarthRadius = 3956.0 miles */
SET @kEarthRadius = 6376.5;        /* kms */

DECLARE @dDistance as real;
SET @dDistance = @kEarthRadius * @c;
return (@dDistance);
END' 
END

/****** Object:  Table [dbo].[Dinners]    Script Date: 02/14/2012 20:34:03 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Dinners]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Dinners](
	[DinnerID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](50) NOT NULL,
	[EventDate] [datetime] NOT NULL,
	[Description] [nvarchar](256) NOT NULL,
	[HostedById] [nvarchar](256) NULL,
	[HostedBy] [nvarchar](256) NOT NULL,
	[ContactPhone] [nvarchar](20) NOT NULL,
	[Address] [nvarchar](50) NOT NULL,
	[Country] [nvarchar](30) NOT NULL,
	[Latitude] [float] NOT NULL,
	[Longitude] [float] NOT NULL,
 CONSTRAINT [PK_Dinners] PRIMARY KEY CLUSTERED 
(
	[DinnerID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END

/****** Object:  Table [dbo].[RSVP]    Script Date: 02/14/2012 20:34:03 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RSVP]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[RSVP](
	[RsvpID] [int] IDENTITY(1,1) NOT NULL,
	[DinnerID] [int] NOT NULL,
	[AttendeeName] [nvarchar](256) NOT NULL,
	[AttendeeNameId] [nvarchar](256) NULL,
 CONSTRAINT [PK_RSVP] PRIMARY KEY CLUSTERED 
(
	[RsvpID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END

/****** Object:  UserDefinedFunction [dbo].[NearestDinners]    Script Date: 02/14/2012 20:34:03 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NearestDinners]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'CREATE FUNCTION [dbo].[NearestDinners]
	(
	@lat real,
	@long real
	)
RETURNS  TABLE
AS
	RETURN
	SELECT     Dinners.DinnerID
	FROM         Dinners 
	WHERE dbo.DistanceBetween(@lat, @long, Latitude, Longitude) <100
' 
END

/****** Object:  ForeignKey [FK_RSVP_Dinners]    Script Date: 02/14/2012 20:34:03 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RSVP_Dinners]') AND parent_object_id = OBJECT_ID(N'[dbo].[RSVP]'))
ALTER TABLE [dbo].[RSVP]  WITH CHECK ADD  CONSTRAINT [FK_RSVP_Dinners] FOREIGN KEY([DinnerID])
REFERENCES [dbo].[Dinners] ([DinnerID])

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_RSVP_Dinners]') AND parent_object_id = OBJECT_ID(N'[dbo].[RSVP]'))
ALTER TABLE [dbo].[RSVP] CHECK CONSTRAINT [FK_RSVP_Dinners]

