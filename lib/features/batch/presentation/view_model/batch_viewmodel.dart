import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/features/batch/domain/usecases/create_batch_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/get_all_batch_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/update_batch_usecase.dart';
import 'package:lost_n_found/features/batch/presentation/state/batch_state.dart';

final BatchViewModelProvider = NotifierProvider<BatchViewModel, BatchState>(() {
  return BatchViewModel();
});

class BatchViewModel extends Notifier<BatchState> {
  late final GetAllBatchUsecase _getAllBatchUsecase;
  late final UpdateBatchUsecase _updateBatchUsecase;
  late final CreateBatchUsecase _createBatchUsecase;

  @override
  BatchState build() {
    _getAllBatchUsecase = ref.read(GetAllBatchUsecaseProvider);
    _updateBatchUsecase = ref.read(UpdateBatchUsecaseProvider);
    _createBatchUsecase = ref.read(createBatchUsecaseProvider);
    return BatchState();
  }

  // Get all batches
  Future<void> getAllBatches() async {
    state = state.copyWith(status: BatchStatus.loading);
    final result = await _getAllBatchUsecase();

    result.fold(
      (left) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: left.message,
        );
      },
      (batches) {
        state = state.copyWith(status: BatchStatus.loaded, batches: batches);
      },
    );
  }

  // Create Batch
  Future<void> createBatch(String batchName) async {
    // progress bar lai ghumau
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _createBatchUsecase(
      CreateBatchUsecaseParams(batchName: batchName),
    );

    result.fold(
      (left) {
        state = state.copyWith(
          status: BatchStatus.error,
          errorMessage: left.message,
        );
      },
      (right) {
        state = state.copyWith(status: BatchStatus.loaded);
      },
    );
  }
}
