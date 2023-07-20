CREATE TABLE IF NOT EXISTS `train` (
    `charidentifier` int(11) NOT NULL,
    `ownedTrains` LONGTEXT DEFAULT '{}',
    FOREIGN KEY (charidentifier) REFERENCES characters ON DELETE CASCADE,
    UNIQUE KEY `charidentifier` (`charidentifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`) VALUES ('bagofcoal', 'Bag Of Coal', 10, 1, 'item_standard', 0);