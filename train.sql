CREATE TABLE IF NOT EXISTS `train` (
    `charidentifier` int(11) NOT NULL,
    `trainid` int NOT NULL AUTO_INCREMENT,
    `trainModel` varchar(50) NOT NULL,
    `fuel` int(11) NOT NULL,
    `condition` int(11) NOT NULL,
    FOREIGN KEY (charidentifier) REFERENCES characters ON DELETE CASCADE,
    PRIMARY KEY(trainid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`) VALUES ('bagofcoal', 'Bag Of Coal', 10, 1, 'item_standard', 0);
INSERT INTO `items`(`item`, `label`, `limit`, `can_remove`, `type`, `usable`) VALUES ('trainoil', 'Train Oil', 10, 1, 'item_standard', 0);