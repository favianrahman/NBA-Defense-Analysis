source("/Users/Favian/Box Sync/sportVU/_functions.R")

# Getting SportVU data for the Spurs-Wolves game
all.movements <- sportvu_convert_json(unzip("/Users/Favian/Box Sync/NBA-Defense-Analysis/0021500431.json.zip"))

# Ordering the data by event ID, which seems to be a marker for a given play
all.movements <- all.movements[order(all.movements$event.id),]

# Since each event ID comprises of multiple "snapshots", we give each snapshot
# a unique ID
# When we join this table with play-by-play data below, this becomes important
# so that we can conserve the order of every snapshot in the game
all.movements$counter <- seq(1, length.out=nrow(all.movements), by=1)

# Getting the play by play data for the game
gameid = "0021500431"
pbp <- get_pbp(gameid)

# Joining the SportVU and play-by-play data by event ID
pbp <- pbp[-1,]
colnames(pbp)[2] <- c('event.id')
#Trying to limit the fields to join to keep the overall size manageable
pbp <- pbp %>% select (event.id,EVENTMSGTYPE,EVENTMSGACTIONTYPE,SCORE)
pbp$event.id <- as.numeric(levels(pbp$event.id))[pbp$event.id]
all.movements <- merge(x = all.movements, y = pbp, by = "event.id", all.x = TRUE)

# The join mixes up the order of the plays
# This is where the counter from before comes in handy
# We just order by the counter to get the order we had before
all.movements <- all.movements[order(all.movements$counter),]

# Getting the distance matrix for the first event ID
pickeventID <- 1
dists_event1 <- player_dist_matrix(pickeventID)

makes <- data.frame()
misses <- data.frame()

for (i in unique(all.movements$event.id)) {
  pickeventID <- i
  if (subset(all.movements, all.movements$event.id==i)$EVENTMSGTYPE == 1) {
    dists_event <- player_dist_matrix(pickeventID)
    makes <- rbind(makes, dists_event)
  } else if (subset(all.movements, all.movements$event.id==i)$EVENTMSGTYPE == 2) {
    dists_event <- player_dist_matrix(pickeventID)
    misses <- rbind(misses, dists_event)
  }
}




