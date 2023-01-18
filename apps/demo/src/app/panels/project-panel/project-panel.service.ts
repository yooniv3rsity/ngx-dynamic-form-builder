import { Injectable } from '@angular/core';
import { plainToInstance } from 'class-transformer-global-storage';
import { BehaviorSubject } from 'rxjs';
import { environment } from '../../../environments/environment';
import { ProjectPanelStepsEnum } from '../../shared/enums/project-panel-steps.enum';
import { Project } from '../../shared/models/project';

@Injectable()
export class ProjectPanelService {
  activatedStep$ = new BehaviorSubject(ProjectPanelStepsEnum.Step1);
  project$ = new BehaviorSubject(
    plainToInstance(Project, environment.defaults?.project)
  );
  clear() {
    this.project$.next(plainToInstance(Project, environment.defaults?.project));
  }
  store(project: Project) {
    this.project$.next(project);
  }
}
