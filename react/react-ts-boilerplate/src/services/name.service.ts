import { BehaviorSubject, Observable } from 'rxjs';

export class NameService {
  // tslint:disable-next-line:variable-name
  private _name$: BehaviorSubject<string> = new BehaviorSubject<string>('');
  // tslint:disable-next-line:variable-name
  private _dirty$: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);

  public get name$(): Observable<string> {
    return this._name$.asObservable();
  }
  public get dirty$(): Observable<boolean> {
    return this._dirty$.asObservable();
  }

  public setName(name: string): void {
    this._dirty$.next(true);
    this._name$.next(name);
  }

}

// Singleton instance
export const nameService = new NameService();
