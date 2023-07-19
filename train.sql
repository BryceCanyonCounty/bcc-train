CREATE TABLE IF NOT EXISTS `train` (
    `charidentifier` int(11) NOT NULL,
    `ownedTrains` LONGTEXT DEFAULT '{}',
    FOREIGN KEY (charidentifier) REFERENCES characters ON DELETE CASCADE,
    UNIQUE KEY `charidentifier` (`charidentifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;