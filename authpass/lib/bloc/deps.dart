import 'package:authpass/bloc/analytics.dart';
import 'package:authpass/bloc/app_data.dart';
import 'package:authpass/bloc/kdbx_bloc.dart';
import 'package:authpass/cloud_storage/cloud_storage_bloc.dart';
import 'package:authpass/env/_base.dart';
import 'package:meta/meta.dart';

/// Global resources available throughout the app (using [Provider])
class Deps {
  factory Deps({@required Env env}) {
    final appDataBloc = AppDataBloc(env);
    final analytics = Analytics(env: env);
    final cloudStorageBloc = CloudStorageBloc(env);
    return Deps._(
      env: env,
      appDataBloc: appDataBloc,
      analytics: analytics,
      kdbxBloc: KdbxBloc(
        env: env,
        appDataBloc: appDataBloc,
        analytics: analytics,
        cloudStorageBloc: cloudStorageBloc,
      ),
      cloudStorageBloc: cloudStorageBloc,
    );
  }

  Deps._({
    @required this.appDataBloc,
    @required this.kdbxBloc,
    @required this.env,
    @required this.analytics,
    @required this.cloudStorageBloc,
  }) {
    appDataBloc.store.load().then((appData) {
      final daysSinceLaunch =
          appData.firstLaunchedAt.difference(DateTime.now()).abs().inDays;
      analytics.events.trackInit(
        userType: appData.manualUserType,
        value: daysSinceLaunch,
      );
    });
  }

  final Env env;
  final AppDataBloc appDataBloc;
  final KdbxBloc kdbxBloc;
  final Analytics analytics;
  final CloudStorageBloc cloudStorageBloc;
}
