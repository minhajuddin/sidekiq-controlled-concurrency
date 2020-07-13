# Controlled Enqueue

Allow jobs to enqueued in a controlled fashion


## Test

Open 3 terminals

The first for sidekiq
```
# 1. sidekiq
$ bundle exec sidekiq --concurrency 10 --require ./app.rb
```

The second for the enqueuer
```
# 2. enqueuer
$ bundle exec ruby ./enqueuer.rb
```

At this point the enqueuer shouldn't be able to enqueue any jobs, because the
concurrency at this stage is set to 0

```
# 3. ruby console
$ bundle exec irb
# set the concurrency to 3
> ControlledEnqueue.increase_concurrency(3)
```

Now you should see 3 jobs enqueuing at a time
