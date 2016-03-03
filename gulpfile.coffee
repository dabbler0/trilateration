gulp = require 'gulp'
coffeeify = require 'gulp-coffeeify'

gulp.task 'browser', ->
  gulp.src(['src/main.coffee', 'src/operator.coffee', 'src/visualization.coffee'])
      .pipe(coffeeify())
      .pipe(gulp.dest './build/')
      .on('done', ->
        gulp.src('./build/*.html')
            .pipe(connect.reload())
      )

gulp.task 'watch', ->
  gulp.watch ['./src/*.coffee'], ['browser']

gulp.task 'default', ['browser']
